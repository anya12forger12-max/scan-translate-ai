import 'package:equatable/equatable.dart';

class OcrResult extends Equatable {
  final String text;
  final String? detectedLanguage;
  final double confidence;
  const OcrResult({required this.text, this.detectedLanguage, this.confidence = 0.0});
  @override List<Object?> get props => [text, detectedLanguage, confidence];
}
