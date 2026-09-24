import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/translation_result.dart';
import '../../domain/repositories/translation_repository.dart';
import '../datasources/translation_datasource.dart';

class TranslationRepositoryImpl implements TranslationRepository {
  final TranslationRemoteDataSource ds;
  TranslationRepositoryImpl({required this.ds});

  @override Future<Either<Failure, TranslationResult>> translate(String text, {String from = 'auto', required String to}) async {
    try { final d = await ds.translate(text, from: from, to: to); return Right(TranslationResult(
      originalText: d['originalText'] as String? ?? text,
      translatedText: d['translatedText'] as String? ?? '',
      sourceLanguage: d['sourceLanguage'] as String? ?? from,
      targetLanguage: d['targetLanguage'] as String? ?? to,
    )); } on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }

  @override Future<Either<Failure, TranslationResult>> translateFromVoice({required String to}) async {
    try { final d = await ds.translateFromVoice(to: to); return Right(TranslationResult(
      originalText: d['originalText'] as String? ?? '',
      translatedText: d['translatedText'] as String? ?? '',
      sourceLanguage: d['sourceLanguage'] as String? ?? 'auto',
      targetLanguage: d['targetLanguage'] as String? ?? to,
    )); } on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }

  @override Future<Either<Failure, TranslationResult>> translateFromCamera({required String to}) async {
    return Left(const ServerFailure('Use OCR first then translate the result.'));
  }

  @override Future<Either<Failure, List<String>>> getSupportedLanguages() async {
    try { return Right(await ds.getSupportedLanguages()); } on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }
}
