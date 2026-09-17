import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Gates ad serving behind Google UMP (GDPR) consent.
///
/// Ads are served only when the UMP flow reaches a definitive "can request
/// ads" outcome: consent obtained, or consent not required. Everything else
/// — platform/plugin/network errors, an unresolved consent status, or a
/// required consent form that is not available yet — fails closed (returns
/// false) and is NOT cached, so the flow re-runs on the next request and a
/// consent decision made later in the session is honored. A definitive
/// "allowed" result is cached for the session.
///
/// Inside a single call the flow is retried a bounded number of times with a
/// short delay so a first-launch EEA user whose consent form only becomes
/// available moments after the info update still gets shown the form. A
/// timeout covers only the non-interactive plumbing (info update, form
/// download) — the consent form itself is shown without a timeout so a user
/// can take as long as they need to decide.
class AdConsentService {
  AdConsentService._();

  static final AdConsentService instance = AdConsentService._();

  static const Duration _plumbingTimeout = Duration(seconds: 20);
  static const Duration _retryDelay = Duration(seconds: 4);
  static const int _maxAttempts = 2;

  Completer<bool>? _inFlight;
  bool _finished = false;
  bool _result = false;

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
      for (var attempt = 1; attempt <= _maxAttempts && !allowed; attempt++) {
        if (attempt > 1) {
          await Future<void>.delayed(_retryDelay);
        }
        try {
          allowed = await _run();
        } catch (error, stackTrace) {
          debugPrint(
              'AdConsentService: consent flow failed on attempt $attempt: '
              '$error\n$stackTrace');
        }
      }
      if (allowed) {
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

  Future<bool> _run() async {
    if (kIsWeb) {
      return true;
    }
    if (!Platform.isAndroid && !Platform.isIOS) {
      return true;
    }

    final consent = ConsentInformation.instance;
    await _updateConsentInfo(consent).timeout(_plumbingTimeout);

    final status = await consent.getConsentStatus();
    if (status == ConsentStatus.required) {
      if (await consent.isConsentFormAvailable()) {
        final form = await _loadForm().timeout(_plumbingTimeout);
        await _showForm(form);
      }
      final after = await consent.getConsentStatus();
      if (after == ConsentStatus.required || after == ConsentStatus.unknown) {
        return false;
      }
      return await consent.canRequestAds();
    }
    if (status == ConsentStatus.unknown) {
      return false;
    }
    return await consent.canRequestAds();
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

  Future<void> _showForm(ConsentForm form) {
    final completer = Completer<void>();
    form.show((_) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    return completer.future;
  }
}