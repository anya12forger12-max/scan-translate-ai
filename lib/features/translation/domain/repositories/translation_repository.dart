import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/translation_result.dart';

abstract class TranslationRepository {
  Future<Either<Failure, TranslationResult>> translate(String text, {String from, required String to});
  Future<Either<Failure, TranslationResult>> translateFromVoice({required String to});
  Future<Either<Failure, TranslationResult>> translateFromCamera({required String to});
  Future<Either<Failure, List<String>>> getSupportedLanguages();
}
