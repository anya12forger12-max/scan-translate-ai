class Env {
  Env._();
  static const String googleApiKey = String.fromEnvironment('GOOGLE_API_KEY', defaultValue: '');
  static const String appName = 'Scan & Translate AI';
  static const String appVersion = '1.0.0';
  static const bool enableCrashlytics = bool.fromEnvironment('ENABLE_CRASHLYTICS', defaultValue: false);
}
