import 'package:flutter_test/flutter_test.dart';

import 'package:scan_translate_ai/features/ocr/presentation/providers/ocr_provider.dart';
import 'package:scan_translate_ai/features/translation/presentation/providers/translation_provider.dart';

void main() {
  group('TranslationNotifier.clearError', () {
    test('clears error status and message without losing languages', () {
      final notifier = TranslationNotifier();
      notifier.setTargetLanguage('fr');
      notifier.setError('Camera capture failed');

      expect(notifier.state.status, TranslationStatus.error);
      expect(notifier.state.errorMessage, 'Camera capture failed');

      notifier.clearError();

      expect(notifier.state.status, TranslationStatus.initial);
      expect(notifier.state.errorMessage, isNull);
      expect(notifier.state.targetLanguage, 'fr');
    });
  });

  group('OcrNotifier.clearError', () {
    test('clears error status and message', () {
      final notifier = OcrNotifier();
      notifier.setError('camera_access_denied');

      expect(notifier.state.status, OcrStatus.error);
      expect(notifier.state.errorMessage, 'camera_access_denied');

      notifier.clearError();

      expect(notifier.state.status, OcrStatus.initial);
      expect(notifier.state.errorMessage, isNull);
    });
  });
}