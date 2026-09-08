import 'dart:ui';

import 'package:equatable/equatable.dart';

class OcrResult extends Equatable {
  final String text;
  final String? detectedLanguage;
  final Map<String, dynamic>? rawData;
  final double confidence;
  final List<OcrBlock> blocks;

  const OcrResult({
    required this.text,
    this.detectedLanguage,
    this.rawData,
    this.confidence = 0.0,
    this.blocks = const [],
  });

  @override
  List<Object?> get props => [text, detectedLanguage, confidence, blocks];
}

class OcrBlock extends Equatable {
  final String text;
  final Rect boundingBox;
  final List<OcrLine> lines;

  const OcrBlock({
    required this.text,
    required this.boundingBox,
    this.lines = const [],
  });

  @override
  List<Object?> get props => [text, boundingBox, lines];
}

class OcrLine extends Equatable {
  final String text;
  final Rect boundingBox;
  final List<OcrElement> elements;

  const OcrLine({
    required this.text,
    required this.boundingBox,
    this.elements = const [],
  });

  @override
  List<Object?> get props => [text, boundingBox, elements];
}

class OcrElement extends Equatable {
  final String text;
  final Rect boundingBox;
  final double confidence;

  const OcrElement({
    required this.text,
    required this.boundingBox,
    this.confidence = 0.0,
  });

  @override
  List<Object?> get props => [text, boundingBox, confidence];
}
