class AppConstants {
  AppConstants._();

  static const String appName = 'Scan & Translate AI';
  static const String appVersion = '1.0.0';
  static const String companyName = 'ScanTranslateAI';
  static const String supportEmail = 'support@scantranslateai.com';
  static const String privacyPolicyUrl = 'https://scantranslateai.com/privacy';
  static const String termsUrl = 'https://scantranslateai.com/terms';

  static const int minPasswordLength = 8;
  static const int maxScanHistoryItems = 500;
  static const int scanCooldownMs = 500;
  static const double minTouchTarget = 48.0;
  static const double cardBorderRadius = 20.0;
  static const double glassBlurIntensity = 10.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration skeletonDelay = Duration(milliseconds: 500);
}
