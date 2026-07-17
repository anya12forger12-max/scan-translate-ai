import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/translation_result.dart';
import '../../domain/repositories/translation_repository.dart';
import '../datasources/translation_datasource.dart';

class TranslationRepositoryImpl implements TranslationRepository {
  final TranslationRemoteDataSource remoteDataSource;

  TranslationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, TranslationResult>> translateText({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    try {
      final data = await remoteDataSource.translateText(
        text: text,
        targetLanguage: targetLanguage,
        sourceLanguage: sourceLanguage,
      );
      return Right(TranslationResult(
        originalText: data['originalText'] as String,
        translatedText: data['translatedText'] as String,
        sourceLanguage: data['sourceLanguage'] as String,
        targetLanguage: data['targetLanguage'] as String,
        confidence: (data['confidence'] as num?)?.toDouble() ?? 0.0,
      ));
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, String>> detectLanguage(String text) async {
    try {
      final lang = await remoteDataSource.detectLanguage(text);
      return Right(lang);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, TranslationResult>> translateVoice({
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    try {
      final recognizedText = await remoteDataSource.speechToTextConverter(
        language: sourceLanguage,
      );
      final translationData = await remoteDataSource.translateText(
        text: recognizedText,
        targetLanguage: targetLanguage,
        sourceLanguage: sourceLanguage,
      );
      return Right(TranslationResult(
        originalText: recognizedText,
        translatedText: translationData['translatedText'] as String,
        sourceLanguage: translationData['sourceLanguage'] as String,
        targetLanguage: targetLanguage,
        confidence: (translationData['confidence'] as num?)?.toDouble() ?? 0.0,
      ));
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, String>> speechToText({
    String? language,
  }) async {
    try {
      final text = await remoteDataSource.speechToTextConverter(
        language: language,
      );
      return Right(text);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> textToSpeech({
    required String text,
    required String language,
  }) async {
    try {
      await remoteDataSource.textToSpeechConverter(
        text: text,
        language: language,
      );
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
