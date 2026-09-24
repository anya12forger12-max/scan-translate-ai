import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

class PrivacyPolicyPage extends StatelessWidget {
  final bool isMandatory;
  const PrivacyPolicyPage({super.key, this.isMandatory = false});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Privacy Policy'),
      leading: isMandatory ? const SizedBox.shrink() : null,
      automaticallyImplyLeading: !isMandatory,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Scan & Translate AI', style: AppTypography.titleLarge),
        const SizedBox(height: 4),
        Text('Last updated: July 2026', style: AppTypography.bodySmall),
        const SizedBox(height: 24),
        _section('1. Information We Collect',
          'We collect minimal information to provide core functionality:\n\n'
          '- Camera access: Used for QR/barcode scanning, OCR, and camera translation.\n'
          '- Microphone access: Used for voice translation (optional).\n'
          '- Photos/Gallery: Used for OCR image selection (optional).\n'
          '- Account data: Email and display name if you register.\n'
          '- Scan/translation history: Stored securely in Firebase.\n'
          '- Usage analytics: Anonymous data to improve the app.'),
        _section('2. How We Use Your Information',
          'Your data is used solely for:\n\n'
          '- Processing QR/barcode scans\n'
          '- Recognizing text from images\n'
          '- Translating text between languages\n'
          '- Saving your preferences and history\n'
          '- Improving app functionality'),
        _section('3. Data Storage & Security',
          'Data is stored on Firebase (Google Cloud Platform) with encryption in transit and at rest. '
          'We implement industry-standard security measures. Your data is never sold or shared with third parties.'),
        _section('4. Third-Party Services',
          'We use:\n\n'
          '- Firebase (Auth, Firestore, Storage): Authentication and cloud data\n'
          '- Google ML Kit: On-device text recognition\n'
          '- Google Gemini: AI-powered translation\n'
          '- mobile_scanner: QR/barcode scanning\n\n'
          'Each service has its own privacy policy governing data handling.'),
        _section('5. Your Rights',
          'You can:\n\n'
          '- Access, modify, or delete your data anytime\n'
          '- Export your data from Firebase Console\n'
          '- Delete your account and all associated data\n'
          '- Revoke permissions (camera, microphone, storage) anytime'),
        _section('6. Children\'s Privacy',
          'This app is not intended for users under 13. We do not knowingly collect data from children.'),
        _section('7. Contact',
          'For privacy inquiries: support@scantranslate.app'),
        const SizedBox(height: 32),
        if (isMandatory) ...[
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 56, child: ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            child: const Text('Accept & Continue'),
          )),
          const SizedBox(height: 16),
        ],
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
