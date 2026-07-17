import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/ocr_result.dart';
import '../../domain/repositories/ocr_repository.dart';
import '../datasources/ocr_datasource.dart';

class OcrRepositoryImpl implements OcrRepository {
  final OcrRemoteDataSource remoteDataSource;

  OcrRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, OcrResult>> recognizeTextFromImage(
      String imagePath) async {
    try {
      final data = await remoteDataSource.recognizeTextFromImage(imagePath);
      return Right(_mapToResult(data));
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, OcrResult>> recognizeTextFromCamera() async {
    try {
      final data = await remoteDataSource.recognizeTextFromCamera();
      return Right(_mapToResult(data));
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, OcrResult>> recognizeTextFromGallery() async {
    try {
      final data = await remoteDataSource.recognizeTextFromGallery();
      return Right(_mapToResult(data));
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  OcrResult _mapToResult(Map<String, dynamic> data) {
    return OcrResult(
      text: data['text'] as String? ?? '',
      detectedLanguage: data['detectedLanguage'] as String?,
      rawData: data,
      confidence: (data['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
