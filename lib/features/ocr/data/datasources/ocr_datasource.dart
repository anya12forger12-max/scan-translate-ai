import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/exceptions.dart';

class OcrRemoteDataSource {
  final ImagePicker picker;
  OcrRemoteDataSource({required this.picker});

  Future<Map<String, dynamic>> recognizeTextFromImage(String path) async {
    final input = InputImage.fromFilePath(path);
    return _process(input);
  }

  Future<Map<String, dynamic>> recognizeTextFromCamera() async {
    final x = await picker.pickImage(source: ImageSource.camera, maxWidth: 1920, maxHeight: 1920, imageQuality: 85);
    if (x == null) throw const OcrException('Camera capture cancelled.');
    return _process(InputImage.fromFilePath(x.path));
  }

  Future<Map<String, dynamic>> recognizeTextFromGallery() async {
    final x = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1920, maxHeight: 1920, imageQuality: 85);
    if (x == null) throw const OcrException('Image selection cancelled.');
    return _process(InputImage.fromFilePath(x.path));
  }

  Future<Map<String, dynamic>> _process(InputImage input) async {
    try {
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final result = await recognizer.processImage(input);
      await recognizer.close();
      if (result.text.isEmpty) throw const OcrException('No text found.');
      return {'text': result.text, 'detectedLanguage': _detectLang(result.text), 'confidence': 0.95};
    } catch (e) {
      if (e is OcrException) rethrow;
      throw OcrException('Text recognition failed.');
    }
  }

  String? _detectLang(String t) {
    if (RegExp("^[a-zA-Z0-9\\s.,!?;'\":-]+\$").hasMatch(t)) return 'en';
    if (RegExp(r'[\u4e00-\u9fff\u3400-\u4dbf]').hasMatch(t)) return 'zh';
    if (RegExp(r'[\u0400-\u04FF]').hasMatch(t)) return 'ru';
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(t)) return 'ar';
    if (RegExp(r'[\u0900-\u097F]').hasMatch(t)) return 'hi';
    return null;
  }
}
