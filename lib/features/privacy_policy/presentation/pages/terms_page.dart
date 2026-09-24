import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Terms & Conditions')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Terms & Conditions', style: AppTypography.titleLarge),
        const SizedBox(height: 4),
        Text('Last updated: July 2026', style: AppTypography.bodySmall),
        const SizedBox(height: 24),
        _section('1. Acceptance',
          'By using Scan & Translate AI, you agree to these terms. If you disagree, do not use the app.'),
        _section('2. License',
          'We grant you a limited, non-exclusive, non-transferable license to use the app for personal purposes.'),
        _section('3. User Obligations',
          'You agree not to misuse the app, violate laws, or infringe on others\' rights. You are responsible for your account.'),
        _section('4. Intellectual Property',
          'All app content, trademarks, and code are owned by us. You may not copy, modify, or redistribute without permission.'),
        _section('5. Limitation of Liability',
          'The app is provided "as is". We are not liable for damages arising from app use.'),
        _section('6. Termination',
          'We may suspend or terminate access for violations of these terms.'),
        _section('7. Changes',
          'We may update these terms. Continued use after changes constitutes acceptance.'),
        _section('8. Contact',
          'For questions: support@scantranslate.app'),
        const SizedBox(height: 32),
      ]),
    ),
  );

  Widget _section(String title, String body) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: AppTypography.titleMedium),
      const SizedBox(height: 8),
      Text(body, style: AppTypography.bodyMedium.copyWith(height: 1.6)),
    ]),
  );
}
