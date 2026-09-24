import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/ocr_result.dart';
import '../../domain/repositories/ocr_repository.dart';
import '../datasources/ocr_datasource.dart';

class OcrRepositoryImpl implements OcrRepository {
  final OcrRemoteDataSource ds;
  OcrRepositoryImpl({required this.ds});

  @override Future<Either<Failure, OcrResult>> recognizeTextFromImage(String path) async {
    try { final d = await ds.recognizeTextFromImage(path); return Right(OcrResult(text: d['text'] ?? '', detectedLanguage: d['detectedLanguage'] as String?)); }
    on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }

  @override Future<Either<Failure, OcrResult>> recognizeTextFromCamera() async {
    try { final d = await ds.recognizeTextFromCamera(); return Right(OcrResult(text: d['text'] ?? '', detectedLanguage: d['detectedLanguage'] as String?)); }
    on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }

  @override Future<Either<Failure, OcrResult>> recognizeTextFromGallery() async {
    try { final d = await ds.recognizeTextFromGallery(); return Right(OcrResult(text: d['text'] ?? '', detectedLanguage: d['detectedLanguage'] as String?)); }
    on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }
}
