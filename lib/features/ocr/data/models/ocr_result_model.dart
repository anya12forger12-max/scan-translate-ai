import '../../domain/entities/ocr_result.dart';

class OcrResultModel {
  final String text;
  final String? detectedLanguage;
  final Map<String, dynamic>? rawData;
  final double confidence;

  const OcrResultModel({
    required this.text,
    this.detectedLanguage,
    this.rawData,
    this.confidence = 0.0,
  });

  factory OcrResultModel.fromMap(Map<String, dynamic> map) {
    return OcrResultModel(
      text: map['text'] as String? ?? '',
      detectedLanguage: map['detectedLanguage'] as String?,
      rawData: map['rawData'] as Map<String, dynamic>?,
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'detectedLanguage': detectedLanguage,
      'rawData': rawData,
      'confidence': confidence,
    };
  }

  OcrResult toEntity() {
    return OcrResult(
      text: text,
      detectedLanguage: detectedLanguage,
      rawData: rawData,
      confidence: confidence,
    );
  }
}
