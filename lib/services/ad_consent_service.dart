import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Gates ad serving behind Google UMP (GDPR) consent.
///
/// Ads are served only when the UMP flow reaches a definitive "can request
/// ads" outcome: consent obtained, or consent not required. Everything else
/// fails closed (ads stay off).
///
/// Only a definitive ALLOW is cached for the session. A blocked outcome is
/// never cached, so the flow re-runs on the next request and a consent
/// decision recorded later (the SDK persisting an earlier choice, or a later
/// visit to the privacy options form) is honored. Caching a blocked outcome
/// would silence the flow for the whole session — an EEA user would be
/// blocked even after granting consent later in the same session.
///
/// Presenting the consent form is rate-limited, not session-latched. A user
/// who just saw the form (whether they declined, dismissed it, or the SDK had
/// not yet persisted their choice) is not bombarded with it: after a
/// presentation the form is not shown again until the re-presentation delay
/// elapses, so banner rebuilds and re-navigations during the same call or
/// shortly after do not re-prompt. But a form that was dismissed without a
/// recorded decision must not seal the user's fate for the whole session:
/// once the delay elapses the form is offered again, so a user whose status
/// is still unresolved can still make a choice instead of being silently
/// blocked with the flow never able to reach a decision.
///
/// The cooldown is measured on two clocks reconciled into one. A monotonic
/// stopwatch supplies the base elapsed time, which is immune to wall-clock
/// jumps in either direction: a clock set forwards must not re-present a form
/// the user just dismissed moments ago, and a clock set backwards must not
/// extend the cooldown forever and re-latch the session. On top of that base,
/// the wall clock contributes ONLY the time the app was demonstrably
/// background-suspended: when a pause/resume cycle is observed through the
/// widget binding, the wall clock's surplus over the frozen stopwatch is real
/// suspension time, and only that surplus is credited. A phone locked or
/// backgrounded for an hour therefore lets the cooldown elapse instead of
/// re-latching the session, while a wall-clock jump that is not accompanied by
/// a real suspend contributes nothing — so no clock manipulation can shorten
/// the cooldown.
///
/// Inside a single call the flow is retried a bounded number of times with a
/// short delay so a first-launch EEA user whose consent form only becomes
/// available moments after the info update still gets shown the form. Once a
/// consent form has actually been presented to the user (show() succeeded),
/// the outcome of that presentation is final for this call: a user who
/// declined or dismissed the form is not shown it again four seconds later.
/// If the form fails to be presented (e.g. the current activity was not
/// ready), that is a transient condition like any other — it is retried and
/// the user is still offered the form. A timeout covers only the
/// non-interactive plumbing (info update, form download) — the consent form
/// itself is shown without a timeout so a user can take as long as they need
/// to decide.
class AdConsentService with WidgetsBindingObserver {
  AdConsentService._();

  static final AdConsentService instance = AdConsentService._();

  static const Duration _plumbingTimeout = Duration(seconds: 20);
  static const Duration _retryDelay = Duration(seconds: 4);
  static const int _maxAttempts = 2;
  static const Duration _minDelayBetweenPresentations = Duration(minutes: 10);

  final Stopwatch _clock = Stopwatch()..start();

  Completer<bool>? _inFlight;
  bool _finished = false;
  bool _result = false;
  Duration? _lastFormShownElapsed;

  bool _observing = false;
  Duration? _pausedElapsed;
  DateTime? _pausedAt;
  Duration _suspendedCredit = Duration.zero;

  /// Returns whether ads may be requested. Never throws.
  Future<bool> ensureConsent() async {
    _ensureObserving();
    if (_finished) {
      return _result;
    }
    final pending = _inFlight;
    if (pending != null) {
      return pending.future;
    }
    final completer = Completer<bool>();
    _inFlight = completer;
    try {
      var allowed = false;
      var formShown = false;
      for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
        if (attempt > 1) {
          await Future<void>.delayed(_retryDelay);
        }
        try {
          final outcome = await _run();
          allowed = outcome.allowed;
          formShown = outcome.formShown;
          if (allowed || formShown) {
            // Definitive for this call: consent granted, or the form was
            // already presented recently and this call must not re-present.
            break;
          }
        } catch (error, stackTrace) {
          debugPrint(
              'AdConsentService: consent flow failed on attempt $attempt: '
              '$error\n$stackTrace');
        }
      }
      if (allowed) {
        // Only a definitive ALLOW is cached. A blocked outcome — even one
        // where the form was shown — is never cached, so the flow re-runs on
        // the next request and a consent decision recorded later in the
        // session is honored instead of a stale session-long denial.
        _finished = true;
        _result = true;
      }
      completer.complete(allowed);
    } catch (error, stackTrace) {
      debugPrint(
          'AdConsentService: consent flow failed, keeping ads off: '
          '$error\n$stackTrace');
      completer.complete(false);
    } finally {
      _inFlight = null;
    }
    return completer.future;
  }

  Future<({bool allowed, bool formShown})> _run() async {
    if (kIsWeb) {
      return (allowed: true, formShown: false);
    }
    if (!Platform.isAndroid && !Platform.isIOS) {
      return (allowed: true, formShown: false);
    }

    final consent = ConsentInformation.instance;
    await _updateConsentInfo(consent).timeout(_plumbingTimeout);

    final status = await consent.getConsentStatus();
    if (status == ConsentStatus.required) {
      if (await consent.isConsentFormAvailable()) {
        final lastShownElapsed = _lastFormShownElapsed;
        final canPresent = lastShownElapsed == null ||
            _elapsedSinceFormShown(lastShownElapsed) >=
                _minDelayBetweenPresentations;
        if (canPresent) {
          final form = await _loadForm().timeout(_plumbingTimeout);
          final presented = await _showForm(form);
          if (!presented) {
            // The form failed to present for the user (e.g. the current
            // activity was not ready). It never reached the user, so this is
            // a transient failure: retry shortly so the form is still
            // offered.
            return (allowed: false, formShown: false);
          }
          // Start a fresh cooldown: clear suspension credit accrued before
          // this presentation along with the stopwatch mark.
          _lastFormShownElapsed = _clock.elapsed;
          _suspendedCredit = Duration.zero;
        }
        // Re-check the status after the presentation (or after a recent
        // presentation). A form that was shown but left the status unresolved
        // is a non-decision: it is reported as shown (so this call stops and
        // does not re-present), the blocked result is not cached, and the
        // presentation delay only temporarily suppresses re-offering — the
        // flow re-runs on later calls and a decision recorded later is
        // honored.
        final after = await consent.getConsentStatus();
        if (after == ConsentStatus.required || after == ConsentStatus.unknown) {
          return (allowed: false, formShown: true);
        }
        return (allowed: await consent.canRequestAds(), formShown: true);
      }
      // Consent is required but the form is not available yet. This is a
      // transient condition: retry shortly so a form that becomes available
      // right after the info update is still presented.
      return (allowed: false, formShown: false);
    }
    if (status == ConsentStatus.unknown) {
      // Status not resolved yet. Transient: retry shortly.
      return (allowed: false, formShown: false);
    }
    return (allowed: await consent.canRequestAds(), formShown: false);
  }

  /// Elapsed time since the consent form was last shown, computed as the
  /// monotonic stopwatch time since that presentation plus the time the app
  /// was demonstrably background-suspended in between. The monotonic base is
  /// immune to wall-clock jumps in either direction: a forward jump cannot
  /// make a just-dismissed form presentable again, and a backward jump cannot
  /// extend the cooldown forever. The suspension credit (accrued only for
  /// observed pause/resume cycles, see [didChangeAppLifecycleState]) makes a
  /// phone locked or backgrounded for an hour count toward the cooldown, so
  /// the session is not silently re-latched by a stopwatch that froze during
  /// suspend.
  Duration _elapsedSinceFormShown(Duration shownElapsed) {
    return (_clock.elapsed - shownElapsed) + _suspendedCredit;
  }

  /// Accrues suspension time so the cooldown counts time spent with the device
  /// asleep or the app backgrounded, where a [Stopwatch] does not advance.
  /// When the app resumes, the wall clock's surplus over the frozen stopwatch
  /// across the observed pause/resume cycle is that genuinely suspended time.
  /// A wall-clock jump that is not accompanied by a real suspend contributes
  /// nothing, so no clock manipulation can shorten the presentation cooldown.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final pausedElapsed = _pausedElapsed;
      final pausedAt = _pausedAt;
      if (pausedElapsed != null && pausedAt != null) {
        final wallGap = DateTime.now().difference(pausedAt);
        final monoGap = _clock.elapsed - pausedElapsed;
        final suspension = wallGap - monoGap;
        if (suspension > Duration.zero) {
          _suspendedCredit += suspension;
        }
      }
      _pausedElapsed = null;
      _pausedAt = null;
      return;
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      _pausedElapsed = _clock.elapsed;
      _pausedAt = DateTime.now();
    }
  }

  void _ensureObserving() {
    if (_observing) {
      return;
    }
    _observing = true;
    try {
      WidgetsBinding.instance.addObserver(this);
    } on Object catch (error) {
      // No widget binding (e.g. headless analysis or a non-application
      // entry): the cooldown then never accrues suspension credit, which is
      // fail-safe — ads can only stay off, never on.
      debugPrint('AdConsentService: no widget binding, ignoring: $error');
    }
  }

  Future<void> _updateConsentInfo(ConsentInformation consent) {
    final completer = Completer<void>();
    consent.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      (error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
    );
    return completer.future;
  }

  Future<ConsentForm> _loadForm() {
    final completer = Completer<ConsentForm>();
    ConsentForm.loadConsentForm(
      (form) {
        if (!completer.isCompleted) {
          completer.complete(form);
        }
      },
      (error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
    );
    return completer.future;
  }

  Future<bool> _showForm(ConsentForm form) {
    final completer = Completer<bool>();
    form.show((error) {
      if (!completer.isCompleted) {
        // A non-null FormError means the form could not be presented
        // (activity not ready, e.g.), so it never reached the user. That is
        // a transient condition, not a user decision.
        completer.complete(error == null);
      }
    });
    return completer.future;
  }
}