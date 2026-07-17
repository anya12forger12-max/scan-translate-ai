class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.scantranslateai.com/v1';
  static const String translationEndpoint = '/translate';
  static const String languageDetectionEndpoint = '/detect-language';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int maxRetries = 3;
}
