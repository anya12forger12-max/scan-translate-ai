import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Centralizes the Google UMP consent flow before AdMob ads are requested.
class AdConsentService {
  AdConsentService._();

  static final AdConsentService instance = AdConsentService._();

  Completer<bool>? _pending;
  bool _finished = false;
  bool _result = true;

  /// Ensures consent is obtained. Never throws; falls back to true.
  Future<bool> ensureConsent() {
    if (_finished) {
      return Future.value(_result);
    }
    final pending = _pending;
    if (pending != null) {
      return pending.future;
    }
    final completer = Completer<bool>();
    _pending = completer;
    _run(completer);
    return completer.future;
  }

  Future<void> _run(Completer<bool> completer) async {
    try {
      if (kIsWeb) {
        _finish(completer, true);
        return;
      }
      if (!Platform.isAndroid && !Platform.isIOS) {
        _finish(completer, true);
        return;
      }

      final info = ConsentInformation.instance;
      await _updateConsentInfo(info);

      final status = await info.getConsentStatus();
      if (status == ConsentStatus.required &&
          await info.isConsentFormAvailable()) {
        final form = await _loadForm();
        await _showForm(form);
      }

      _finish(completer, await info.canRequestAds());
    } catch (error) {
      debugPrint('AdConsentService: consent flow failed: $error');
      _finish(completer, true);
    }
  }

  Future<void> _updateConsentInfo(ConsentInformation info) {
    final completer = Completer<void>();
    info.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      completer.complete,
      (error) => completer.completeError(error),
    );
    return completer.future;
  }

  Future<ConsentForm> _loadForm() {
    final completer = Completer<ConsentForm>();
    ConsentForm.loadConsentForm(
      completer.complete,
      (error) => completer.completeError(error),
    );
    return completer.future;
  }

  Future<void> _showForm(ConsentForm form) {
    final completer = Completer<void>();
    form.show((_) => completer.complete());
    return completer.future;
  }

  void _finish(Completer<bool> completer, bool value) {
    _result = value;
    _finished = true;
    _pending = null;
    if (!completer.isCompleted) {
      completer.complete(value);
    }
  }
}