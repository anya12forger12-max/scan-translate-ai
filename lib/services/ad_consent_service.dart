import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
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
/// The one thing remembered across a blocked outcome is that the consent form
/// has already been presented once this session. A user who already saw the
/// form and declined or dismissed it is never shown it again automatically,
/// but the flow still re-runs on later calls to re-check the status so a
/// decision recorded later is honored.
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
class AdConsentService {
  AdConsentService._();

  static final AdConsentService instance = AdConsentService._();

  static const Duration _plumbingTimeout = Duration(seconds: 20);
  static const Duration _retryDelay = Duration(seconds: 4);
  static const int _maxAttempts = 2;

  Completer<bool>? _inFlight;
  bool _finished = false;
  bool _result = false;
  bool _formShownThisSession = false;

  /// Returns whether ads may be requested. Never throws.
  Future<bool> ensureConsent() async {
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
            // Definitive for this call: consent granted, or the user already
            // saw the form this session and needs no re-presentation.
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
        if (!_formShownThisSession) {
          final form = await _loadForm().timeout(_plumbingTimeout);
          final presented = await _showForm(form);
          if (!presented) {
            // The form failed to present for the user (e.g. the current
            // activity was not ready). It never reached the user, so this is
            // a transient failure: retry shortly so the form is still
            // offered.
            return (allowed: false, formShown: false);
          }
          _formShownThisSession = true;
        }
        // The form has been presented this call or earlier in this session.
        // Never present it again automatically; re-check the status so a
        // decision recorded later is honored. A form that was shown but left
        // the status unresolved is a non-decision: it is reported as shown
        // (so this call stops), but the blocked result is not cached so the
        // flow re-runs and can grant ads if consent is recorded later.
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