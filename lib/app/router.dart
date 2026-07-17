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
import '../features/home/presentation/pages/home_page.dart';
import '../core/theme/app_colors.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return _buildPageRoute(const LoginPage(), settings);

      case '/register':
        return _buildPageRoute(const RegisterPage(), settings);

      case '/forgot-password':
        return _buildPageRoute(const ForgotPasswordPage(), settings);

      case '/email-verification':
        return _buildPageRoute(const EmailVerificationPage(), settings);

      case '/home':
        return _buildPageRoute(const HomePage(), settings);

      case '/qr-scanner':
        return _buildPageRoute(const QrScannerPage(), settings);

      case '/barcode-scanner':
        return _buildPageRoute(const BarcodeScannerPage(), settings);

      case '/ocr':
        return _buildPageRoute(const OcrPage(), settings);

      case '/translate':
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildPageRoute(
          TextTranslationPage(initialText: args?['text'] as String?),
          settings,
        );

      case '/camera-translate':
        return _buildPageRoute(const CameraTranslationPage(), settings);

      case '/voice-translate':
        return _buildPageRoute(const VoiceTranslationPage(), settings);

      case '/history':
        return _buildPageRoute(const HistoryPage(), settings);

      case '/settings':
        return _buildPageRoute(const SettingsPage(), settings);

      case '/privacy-policy':
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildPageRoute(
          PrivacyPolicyPage(
            isMandatory: args?['mandatory'] as bool? ?? false,
          ),
          settings,
        );

      case '/terms':
        return _buildPageRoute(
          const TermsPage(),
          settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                'Route not found: ${settings.name}',
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ),
          settings: settings,
        );
    }
  }

  static PageRoute _buildPageRoute(Widget page, RouteSettings settings) {
    return _CustomPageRoute(page: page, settings: settings);
  }
}

class _CustomPageRoute extends PageRouteBuilder {
  final Widget page;
  final RouteSettings settings;

  _CustomPageRoute({required this.page, required this.settings})
      : super(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            final tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve));
            final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        );
}
