import 'dart:async';

import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../core/errors/exceptions.dart';

class TranslationRemoteDataSource {
  static final OnDeviceTranslatorModelManager _modelManager =
      OnDeviceTranslatorModelManager();

  final FlutterTts flutterTts;
  final stt.SpeechToText speechToText;

  Completer<void>? _cancelSpeechCompleter;

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
      throw const TranslationException(
        'Translation is not available for the selected language pair.',
        code: 'unsupported-language-pair',
      );
    }

    try {
      final modelManager = _modelManager;
      if (!await modelManager.isModelDownloaded(sourceLang.bcpCode)) {
        await modelManager.downloadModel(sourceLang.bcpCode);
      }
      if (!await modelManager.isModelDownloaded(targetLang.bcpCode)) {
        await modelManager.downloadModel(targetLang.bcpCode);
      }

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
    } catch (e) {
      throw TranslationException('Translation failed: ${e.toString()}');
    }
  }

  Future<String> detectLanguage(String text) async {
    return _simpleDetect(text);
  }

  Future<String> speechToTextConverter({
    String? language,
  }) async {
    final resultCompleter = Completer<String>();
    final cancelCompleter = _cancelSpeechCompleter = Completer<void>();
    var stopRequested = false;

    Future<void> requestStop() async {
      if (stopRequested) return;
      stopRequested = true;
      try {
        await speechToText.stop();
      } catch (_) {
        // The recognizer may already be shutting down (e.g. listenFor elapsed).
      }
    }

    try {
      final available = await speechToText.initialize();
      if (!available) {
        throw const SpeechException('Speech recognition not available.');
      }

      if (cancelCompleter.isCompleted) {
        throw const SpeechException('No speech detected.');
      }

      await speechToText.listen(
        onResult: (result) {
          if (!result.finalResult || resultCompleter.isCompleted) return;
          resultCompleter.complete(result.recognizedWords.trim());
          requestStop();
        },
        localeId: language,
        listenFor: const Duration(seconds: 15),
        partialResults: false,
      );

      if (cancelCompleter.isCompleted) {
        await requestStop();
        throw const SpeechException('No speech detected.');
      }

      final recognizedText = await Future.any<String>([
        resultCompleter.future,
        cancelCompleter.future.then((_) => ''),
      ]).timeout(
        const Duration(seconds: 16),
        onTimeout: () {
          requestStop();
          return '';
        },
      );

      if (recognizedText.isEmpty) {
        throw const SpeechException('No speech detected.');
      }

      return recognizedText;
    } catch (e) {
      if (e is SpeechException) rethrow;
      throw SpeechException('Speech recognition failed: ${e.toString()}');
    } finally {
      if (identical(_cancelSpeechCompleter, cancelCompleter)) {
        _cancelSpeechCompleter = null;
      }
    }
  }

  /// Cancels the active speech recognition session, if any.
  Future<void> cancelCurrentSpeechRecognition() async {
    final cancelCompleter = _cancelSpeechCompleter;
    if (cancelCompleter != null && !cancelCompleter.isCompleted) {
      cancelCompleter.complete();
    }
    try {
      await speechToText.stop();
    } catch (_) {
      // No active session or stop already in progress; nothing to cancel.
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