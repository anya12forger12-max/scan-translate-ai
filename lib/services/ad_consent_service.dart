import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Gates ad serving behind Google UMP (GDPR) consent.
///
/// Ads are only served once the UMP flow reaches a definite "can request ads"
/// state. The flow fails closed: if consent status cannot be determined (e.g.
/// platform/plugin/network errors, or a required consent form was not
/// resolvable), ads stay off and the flow is retried on the next call. The
/// result is cached only when it is decisive, so consent granted later in the
/// session is honored.
class AdConsentService {
  AdConsentService._();

  static final AdConsentService instance = AdConsentService._();

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
      final result = await _run();
      _finished = true;
      _result = result;
      completer.complete(result);
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
    await _updateConsentInfo(consent);

    final status = await consent.getConsentStatus();
    if (status == ConsentStatus.required) {
      if (await consent.isConsentFormAvailable()) {
        final form = await _loadForm();
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