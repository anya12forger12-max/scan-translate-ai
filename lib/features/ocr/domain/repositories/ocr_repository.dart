import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ocr_result.dart';

abstract class OcrRepository {
  Future<Either<Failure, OcrResult>> recognizeTextFromImage(String imagePath);

  Future<Either<Failure, OcrResult>> recognizeTextFromCamera();

  Future<Either<Failure, OcrResult>> recognizeTextFromGallery();
}
