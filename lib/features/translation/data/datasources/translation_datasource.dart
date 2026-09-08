import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../core/errors/exceptions.dart';

class TranslationRemoteDataSource {
  final FlutterTts flutterTts;
  final stt.SpeechToText speechToText;

  TranslationRemoteDataSource({
    required this.flutterTts,
    required this.speechToText,
  });

  Future<Map<String, dynamic>> translateText({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    final effectiveSource = (sourceLanguage == null || sourceLanguage == 'auto')
        ? _simpleDetect(text)
        : sourceLanguage;

    final sourceLang = _toTranslateLanguage(effectiveSource);
    final targetLang = _toTranslateLanguage(targetLanguage);

    if (sourceLang == null || targetLang == null) {
      return _simulateTranslation(text, targetLanguage, sourceLanguage);
    }

    try {
      final modelManager = OnDeviceTranslatorModelManager();
      await modelManager.downloadModel(sourceLang.bcpCode);
      await modelManager.downloadModel(targetLang.bcpCode);

      final translator =
          OnDeviceTranslator(sourceLanguage: sourceLang, targetLanguage: targetLang);
      try {
        final translatedText = await translator.translateText(text);
        return {
          'originalText': text,
          'translatedText': translatedText,
          'sourceLanguage': effectiveSource,
          'targetLanguage': targetLanguage,
          'confidence': 1.0,
        };
      } finally {
        await translator.close();
      }
    } catch (_) {
      return _simulateTranslation(text, targetLanguage, sourceLanguage);
    }
  }

  Future<String> detectLanguage(String text) async {
    return _simpleDetect(text);
  }

  Future<String> speechToTextConverter({
    String? language,
  }) async {
    try {
      final available = await speechToText.initialize();
      if (!available) {
        throw const SpeechException('Speech recognition not available.');
      }

      String? recognizedText;
      await speechToText.listen(
        onResult: (result) {
          recognizedText = result.recognizedWords;
        },
        localeId: language,
        listenFor: const Duration(seconds: 10),
        partialResults: false,
      );

      await Future.delayed(const Duration(seconds: 10));
      await speechToText.stop();

      if (recognizedText == null || recognizedText!.isEmpty) {
        throw const SpeechException('No speech detected.');
      }

      return recognizedText!;
    } catch (e) {
      if (e is SpeechException) rethrow;
      throw SpeechException('Speech recognition failed: ${e.toString()}');
    }
  }

  Future<void> textToSpeechConverter({
    required String text,
    required String language,
  }) async {
    try {
      await flutterTts.setLanguage(language);
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.speak(text);
    } catch (e) {
      throw SpeechException('Text-to-speech failed: ${e.toString()}');
    }
  }

  Future<bool> isSpeechRecognitionAvailable() async {
    return await speechToText.initialize();
  }

  TranslateLanguage? _toTranslateLanguage(String? code) {
    if (code == null) return null;
    for (final language in TranslateLanguage.values) {
      if (language.bcpCode == code) return language;
    }
    return null;
  }

  Map<String, dynamic> _simulateTranslation(
    String text,
    String targetLanguage,
    String? sourceLanguage,
  ) {
    return {
      'originalText': text,
      'translatedText': '[${targetLanguage.toUpperCase()}] $text',
      'sourceLanguage': sourceLanguage ?? 'auto',
      'targetLanguage': targetLanguage,
      'confidence': 0.5,
    };
  }

  String _simpleDetect(String text) {
    final latinChars = RegExp(r'^[\x20-\x7E]+$');
    if (latinChars.hasMatch(text)) return 'en';
    final cjkChars = RegExp(r'[\u4e00-\u9fff\u3400-\u4dbf]');
    if (cjkChars.hasMatch(text)) return 'zh';
    final cyrillicChars = RegExp(r'[\u0400-\u04FF]');
    if (cyrillicChars.hasMatch(text)) return 'ru';
    final arabicChars = RegExp(r'[\u0600-\u06FF]');
    if (arabicChars.hasMatch(text)) return 'ar';
    final devanagariChars = RegExp(r'[\u0900-\u097F]');
    if (devanagariChars.hasMatch(text)) return 'hi';
    return 'en';
  }
}