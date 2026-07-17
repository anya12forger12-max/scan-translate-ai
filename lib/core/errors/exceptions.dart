sealed class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

class CacheException extends AppException {
  const CacheException(super.message, {super.code});
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

class PermissionException extends AppException {
  const PermissionException(super.message, {super.code});
}

class CameraException extends AppException {
  const CameraException(super.message, {super.code});
}

class ScannerException extends AppException {
  const ScannerException(super.message, {super.code});
}

class OcrException extends AppException {
  const OcrException(super.message, {super.code});
}

class TranslationException extends AppException {
  const TranslationException(super.message, {super.code});
}

class SpeechException extends AppException {
  const SpeechException(super.message, {super.code});
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}
