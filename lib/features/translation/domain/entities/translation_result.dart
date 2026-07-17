import 'package:equatable/equatable.dart';

class TranslationResult extends Equatable {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final double confidence;

  const TranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.confidence = 0.0,
  });

  @override
  List<Object?> get props => [
        originalText,
        translatedText,
        sourceLanguage,
        targetLanguage,
        confidence,
      ];
}

class Language {
  final String code;
  final String name;
  final String? nativeName;

  const Language({
    required this.code,
    required this.name,
    this.nativeName,
  });

  static const List<Language> supported = [
    Language(code: 'en', name: 'English', nativeName: 'English'),
    Language(code: 'es', name: 'Spanish', nativeName: 'Español'),
    Language(code: 'fr', name: 'French', nativeName: 'Français'),
    Language(code: 'de', name: 'German', nativeName: 'Deutsch'),
    Language(code: 'it', name: 'Italian', nativeName: 'Italiano'),
    Language(code: 'pt', name: 'Portuguese', nativeName: 'Português'),
    Language(code: 'ru', name: 'Russian', nativeName: 'Русский'),
    Language(code: 'zh', name: 'Chinese', nativeName: '中文'),
    Language(code: 'ja', name: 'Japanese', nativeName: '日本語'),
    Language(code: 'ko', name: 'Korean', nativeName: '한국어'),
    Language(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    Language(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी'),
    Language(code: 'bn', name: 'Bengali', nativeName: 'বাংলা'),
    Language(code: 'pa', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ'),
    Language(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்'),
    Language(code: 'te', name: 'Telugu', nativeName: 'తెలుగు'),
    Language(code: 'mr', name: 'Marathi', nativeName: 'मराठी'),
    Language(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી'),
    Language(code: 'tr', name: 'Turkish', nativeName: 'Türkçe'),
    Language(code: 'nl', name: 'Dutch', nativeName: 'Nederlands'),
    Language(code: 'pl', name: 'Polish', nativeName: 'Polski'),
    Language(code: 'th', name: 'Thai', nativeName: 'ไทย'),
    Language(code: 'vi', name: 'Vietnamese', nativeName: 'Tiếng Việt'),
    Language(code: 'id', name: 'Indonesian', nativeName: 'Bahasa Indonesia'),
    Language(code: 'ms', name: 'Malay', nativeName: 'Bahasa Melayu'),
    Language(code: 'fa', name: 'Persian', nativeName: 'فارسی'),
    Language(code: 'uk', name: 'Ukrainian', nativeName: 'Українська'),
    Language(code: 'ro', name: 'Romanian', nativeName: 'Română'),
    Language(code: 'cs', name: 'Czech', nativeName: 'Čeština'),
    Language(code: 'el', name: 'Greek', nativeName: 'Ελληνικά'),
    Language(code: 'sv', name: 'Swedish', nativeName: 'Svenska'),
    Language(code: 'da', name: 'Danish', nativeName: 'Dansk'),
    Language(code: 'fi', name: 'Finnish', nativeName: 'Suomi'),
    Language(code: 'no', name: 'Norwegian', nativeName: 'Norsk'),
  ];
}
