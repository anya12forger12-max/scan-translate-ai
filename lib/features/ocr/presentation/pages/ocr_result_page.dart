import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/loading_display.dart';
import '../../domain/entities/ocr_result.dart';
import '../widgets/ocr_text_display.dart';

class OcrResultPage extends StatelessWidget {
  final OcrResult result;

  const OcrResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Result'),
      ),
      body: SingleChildScrollView(
        child: OcrTextDisplay(
          text: result.text,
          detectedLanguage: result.detectedLanguage,
          onTranslate: () {
            Navigator.pushNamed(
              context,
              '/translate',
              arguments: {'text': result.text},
            );
          },
          onShare: () {
            Share.share(result.text);
          },
        ),
      ),
    );
  }
}
