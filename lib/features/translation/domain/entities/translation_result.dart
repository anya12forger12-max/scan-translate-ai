import 'package:equatable/equatable.dart';

class TranslationResult extends Equatable {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final double confidence;
  const TranslationResult({required this.originalText, required this.translatedText, required this.sourceLanguage, required this.targetLanguage, this.confidence = 0.0});
  @override List<Object?> get props => [originalText, translatedText, sourceLanguage, targetLanguage, confidence];
}
