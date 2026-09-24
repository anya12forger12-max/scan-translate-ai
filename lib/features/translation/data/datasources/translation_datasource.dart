import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../core/config/env.dart';
import '../../../../core/errors/exceptions.dart';

class TranslationRemoteDataSource {
  final FlutterTts flutterTts;
  final stt.SpeechToText speechToText;
  final GenerativeModel model;

  TranslationRemoteDataSource({required this.flutterTts, required this.speechToText})
    : model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: Env.googleApiKey);

  Future<Map<String, dynamic>> translate(String text, {String from = 'auto', required String to}) async {
    final prompt = 'Translate the following text from ${from == 'auto' ? 'auto-detected language' : from} to $to. '
      'Return ONLY a JSON object with keys "translatedText", "sourceLanguage". No markdown, no backticks.\n\nText: $text';
    final r = await model.generateContent([Content.text(prompt)]);
    final body = r.text;
    if (body == null || body.isEmpty) throw const TranslationException('No translation returned.');
    final cleaned = body.replaceAll(RegExp(r'^```(?:json)?\s*', multiLine: true), '').replaceAll(RegExp(r'\s*```$', multiLine: true), '').trim();
    final map = _parseJson(cleaned);
    return {'translatedText': map['translatedText'] as String? ?? '', 'sourceLanguage': map['sourceLanguage'] as String? ?? 'auto', 'targetLanguage': to, 'originalText': text};
  }

  Future<Map<String, dynamic>> translateFromVoice({required String to}) async {
    final avail = await speechToText.initialize();
    if (!avail) throw const TranslationException('Speech recognition not available.');
    String? heard;
    await speechToText.listen(onResult: (r) { if (heard == null && r.recognizedWords.isNotEmpty) heard = r.recognizedWords; });
    await Future.delayed(const Duration(seconds: 5));
    await speechToText.stop();
    if (heard == null || heard!.isEmpty) throw const TranslationException('No speech detected.');
    return translate(heard!, from: 'auto', to: to);
  }

  Future<Map<String, dynamic>> translateFromCamera({required String to}) async {
    throw UnimplementedError('Use OcrRepository + TranslationRepository chain');
  }

  Future<List<String>> getSupportedLanguages() async =>
    ['af','sq','am','ar','hy','az','eu','be','bn','bs','bg','ca','ceb','zh','zh-TW','co','hr','cs','da','nl','en','eo','et','fi','fr','fy','gl','ka','de','el','gu','ht','ha','haw','iw','hi','hmn','hu','is','ig','id','ga','it','ja','jv','kn','kk','km','rw','ko','ku','ky','lo','la','lv','lt','lb','mk','mg','ms','ml','mt','mi','mr','mn','my','ne','no','ny','or','ps','fa','pl','pt','pa','ro','ru','sm','gd','sr','st','sn','sd','si','sk','sl','so','es','su','sw','sv','tl','tg','ta','tt','te','th','tr','tk','uk','ur','ug','uz','vi','cy','xh','yi','yo','zu'];

  Map<String, dynamic> _parseJson(String s) {
    try { return Map<String, dynamic>.from(Map.fromEntries(s.replaceAll(RegExp(r'[{}"]'), '').split(',').map((e) {
      final parts = e.split(':').map((x) => x.trim()).toList();
      return MapEntry(parts[0], parts.length > 1 ? parts.sublist(1).join(':') : '');
    }))); } catch (_) { return {'translatedText': s, 'sourceLanguage': 'auto'}; }
  }
}
