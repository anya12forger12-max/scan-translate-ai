import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/translation_result.dart';

abstract class TranslationRepository {
  Future<Either<Failure, TranslationResult>> translateText({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  });

  Future<Either<Failure, String>> detectLanguage(String text);

  Future<Either<Failure, TranslationResult>> translateVoice({
    required String targetLanguage,
    String? sourceLanguage,
  });

  Future<Either<Failure, String>> speechToText({
    String? language,
  });

  Future<Either<Failure, void>> textToSpeech({
    required String text,
    required String language,
  });
}
