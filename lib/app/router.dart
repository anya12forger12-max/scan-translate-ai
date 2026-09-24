import 'package:flutter/material.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/email_verification_page.dart';
import '../features/scanner/presentation/pages/qr_scanner_page.dart';
import '../features/scanner/presentation/pages/barcode_scanner_page.dart';
import '../features/ocr/presentation/pages/ocr_page.dart';
import '../features/translation/presentation/pages/text_translation_page.dart';
import '../features/translation/presentation/pages/camera_translation_page.dart';
import '../features/translation/presentation/pages/voice_translation_page.dart';
import '../features/history/presentation/pages/history_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/privacy_policy/presentation/pages/privacy_policy_page.dart';
import '../features/privacy_policy/presentation/pages/terms_page.dart';
import '../features/home/presentation/pages/home_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case '/login': page = const LoginPage();
      case '/register': page = const RegisterPage();
      case '/forgot-password': page = const ForgotPasswordPage();
      case '/email-verification': page = const EmailVerificationPage();
      case '/home': page = const HomePage();
      case '/qr-scanner': page = const QrScannerPage();
      case '/barcode-scanner': page = const BarcodeScannerPage();
      case '/ocr': page = const OcrPage();
      case '/translate':
        final args = settings.arguments as Map<String, dynamic>?;
        page = TextTranslationPage(initialText: args?['text'] as String?);
      case '/camera-translate': page = const CameraTranslationPage();
      case '/voice-translate': page = const VoiceTranslationPage();
      case '/history': page = const HistoryPage();
      case '/settings': page = const SettingsPage();
      case '/privacy-policy':
        final args = settings.arguments as Map<String, dynamic>?;
        page = PrivacyPolicyPage(
            isMandatory: args?['mandatory'] as bool? ?? false);
      case '/terms': page = const TermsPage();
      default: page = Scaffold(
          body: Center(child: Text('Route: ${settings.name}')),
        );
    }
    return _slideTransition(page, settings);
  }

  static PageRoute _slideTransition(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0), end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation, curve: Curves.easeInOutCubic,
          )),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
