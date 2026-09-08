import 'exceptions.dart';

sealed class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code});
}

class CameraFailure extends Failure {
  const CameraFailure(super.message, {super.code});
}

class ScannerFailure extends Failure {
  const ScannerFailure(super.message, {super.code});
}

class OcrFailure extends Failure {
  const OcrFailure(super.message, {super.code});
}

class TranslationFailure extends Failure {
  const TranslationFailure(super.message, {super.code});
}

class SpeechFailure extends Failure {
  const SpeechFailure(super.message, {super.code});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

Failure mapExceptionToFailure(AppException exception) {
  return switch (exception) {
    ServerException e => ServerFailure(e.message, code: e.code),
    CacheException e => CacheFailure(e.message, code: e.code),
    AuthException e => AuthFailure(e.message, code: e.code),
    NetworkException e => NetworkFailure(e.message, code: e.code),
    PermissionException e => PermissionFailure(e.message, code: e.code),
    CameraException e => CameraFailure(e.message, code: e.code),
    ScannerException e => ScannerFailure(e.message, code: e.code),
    OcrException e => OcrFailure(e.message, code: e.code),
    TranslationException e => TranslationFailure(e.message, code: e.code),
    SpeechException e => SpeechFailure(e.message, code: e.code),
    ValidationException e => ValidationFailure(e.message, code: e.code),
  };
}
