import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/ssl_pinning.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class TranslationRemoteDataSource {
  final FlutterTts flutterTts;
  final stt.SpeechToText speechToText;
  final String? apiKey;

  TranslationRemoteDataSource({
    required this.flutterTts,
    required this.speechToText,
    this.apiKey,
  });

  Future<Map<String, dynamic>> translateText({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    try {
      if (apiKey == null || apiKey!.isEmpty) {
        return _simulateTranslation(text, targetLanguage, sourceLanguage);
      }

      final client = await SslPinningConfig.createHttpClient();
      try {
        final response = await client
            .post(
              Uri.parse('${ApiConstants.baseUrl}${ApiConstants.translationEndpoint}'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $apiKey',
              },
              body: jsonEncode({
                'q': text,
                'source': sourceLanguage ?? 'auto',
                'target': targetLanguage,
                'format': 'text',
              }),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return {
            'originalText': text,
            'translatedText': data['translatedText'] ?? '',
            'sourceLanguage': data['detectedSourceLanguage'] ?? sourceLanguage ?? 'auto',
            'targetLanguage': targetLanguage,
            'confidence': data['confidence'] ?? 0.0,
          };
        }
        throw TranslationException('Translation failed: ${response.statusCode}');
      } finally {
        client.close();
      }
    } catch (e) {
      if (e is TranslationException) rethrow;
      return _simulateTranslation(text, targetLanguage, sourceLanguage);
    }
  }

  Future<String> detectLanguage(String text) async {
    try {
      if (apiKey == null || apiKey!.isEmpty) {
        return _simpleDetect(text);
      }

      final client = await SslPinningConfig.createHttpClient();
      try {
        final response = await client
            .post(
              Uri.parse(
                  '${ApiConstants.baseUrl}${ApiConstants.languageDetectionEndpoint}'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $apiKey',
              },
              body: jsonEncode({'q': text}),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return data['language'] as String? ?? 'en';
        }
        return 'en';
      } finally {
        client.close();
      }
    } catch (_) {
      return _simpleDetect(text);
    }
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
    final latinChars = RegExp(r'^[a-zA-Z0-9\s.,!?;:\'"-]+$');
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
