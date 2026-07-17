import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/exceptions.dart';

class OcrRemoteDataSource {
  final ImagePicker imagePicker;

  OcrRemoteDataSource({required this.imagePicker});

  Future<Map<String, dynamic>> recognizeTextFromImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      return await _processImage(inputImage);
    } catch (e) {
      throw OcrException('Failed to recognize text: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> recognizeTextFromCamera() async {
    try {
      final xFile = await imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (xFile == null) {
        throw const OcrException('Camera capture cancelled.');
      }
      final inputImage = InputImage.fromFilePath(xFile.path);
      return await _processImage(inputImage);
    } on OcrException {
      rethrow;
    } catch (e) {
      throw OcrException('Failed to capture image: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> recognizeTextFromGallery() async {
    try {
      final xFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (xFile == null) {
        throw const OcrException('Image selection cancelled.');
      }
      final inputImage = InputImage.fromFilePath(xFile.path);
      return await _processImage(inputImage);
    } on OcrException {
      rethrow;
    } catch (e) {
      throw OcrException('Failed to pick image: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> _processImage(InputImage inputImage) async {
    try {
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      if (recognizedText.text.isEmpty) {
        throw const OcrException('No text found in the image.');
      }

      return {
        'text': recognizedText.text,
        'detectedLanguage': _detectLanguage(recognizedText.text),
        'confidence': 0.95,
        'blocks': recognizedText.blocks.map((block) => {
          'text': block.text,
          'boundingBox': {
            'left': block.boundingBox.left,
            'top': block.boundingBox.top,
            'width': block.boundingBox.width,
            'height': block.boundingBox.height,
          },
          'lines': block.lines.map((line) => {
            'text': line.text,
            'boundingBox': {
              'left': line.boundingBox.left,
              'top': line.boundingBox.top,
              'width': line.boundingBox.width,
              'height': line.boundingBox.height,
            },
            'elements': line.elements.map((element) => {
              'text': element.text,
              'boundingBox': {
                'left': element.boundingBox.left,
                'top': element.boundingBox.top,
                'width': element.boundingBox.width,
                'height': element.boundingBox.height,
              },
              'confidence': element.confidence,
            }).toList(),
          }).toList(),
        }).toList(),
      };
    } catch (e) {
      if (e is OcrException) rethrow;
      throw OcrException('Text recognition failed: ${e.toString()}');
    }
  }

  String? _detectLanguage(String text) {
    final latinChars = RegExp(r'^[a-zA-Z0-9\s.,!?;:\'"-]+$');
    if (latinChars.hasMatch(text)) return 'en';
    final cjkChars = RegExp(r'[\u4e00-\u9fff\u3400-\u4dbf]');
    if (cjkChars.hasMatch(text)) return 'zh';
    final cyrillicChars = RegExp(r'[\u0400-\u04FF]');
    if (cyrillicChars.hasMatch(text)) return 'ru';
    final arabicChars = RegExp(r'[\u0600-\u06FF]');
    if (arabicChars.hasMatch(text)) return 'ar';
    return null;
  }
}
