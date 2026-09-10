import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/privacy_policy_provider.dart';

class PrivacyPolicyPage extends ConsumerStatefulWidget {
  final bool isMandatory;

  const PrivacyPolicyPage({super.key, this.isMandatory = false});

  @override
  ConsumerState<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends ConsumerState<PrivacyPolicyPage> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    final privacyState = ref.watch(privacyPolicyProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return PopScope(
      canPop: !widget.isMandatory,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Privacy Policy'),
          leading: widget.isMandatory
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      label: 'Privacy Policy heading',
                      child: Text(
                        'Privacy Policy',
                        style: AppTypography.headlineLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Semantics(
                      label: 'Last updated date',
                      child: Text(
                        'Last Updated: September 2026',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      '1. Information We Collect',
                      'We collect information you provide when creating an account, including your email address and display name. When you use scanning features, the content of scanned QR codes, barcodes, and recognized text is stored locally on your device and in your secure cloud account.'
                    ),
                    _buildSection(
                      '2. How We Use Your Information',
                      'Your information is used solely to provide and improve our services. This includes authenticating your identity, storing your scan history, enabling cloud backup, and providing customer support when needed.'
                    ),
                    _buildSection(
                      '3. Data Access & Security',
                      '• You can only access your own data.\n'
                      '• One user can never view another user\'s information.\n'
                      '• The administrator (the app owner/creator) is the only authorized person who may access collected user data through a secure administrative interface for maintenance, customer support, analytics, security investigations, or legal compliance.\n'
                      '• The admin interface is not accessible to regular users.\n'
                      '• User data is protected during transmission and storage using industry-standard encryption and secure authentication.'
                    ),
                    _buildSection(
                      '4. Data Storage & Protection',
                      'We use industry-standard encryption (TLS/SSL) for data transmission. Your data is stored securely using Firebase with encrypted storage. We implement strict access controls and authentication mechanisms to protect your personal information.'
                    ),
                    _buildSection(
                      '5. Your Rights',
                      'You have the right to:\n'
                      '• Access your personal data\n'
                      '• Delete your account and associated data\n'
                      '• Export your scan history\n'
                      '• Withdraw consent at any time\n'
                      '• Request information about how your data is used'
                    ),
                    _buildSection(
                      '6. Third-Party Services',
                      'We use Firebase (Google) for authentication, database, and storage services. These services have their own privacy policies and security measures. We also use ML Kit for on-device text recognition, which processes images locally without sending them to external servers.'
                    ),
                    _buildSection(
                      '7. Advertising and Advertising IDs',
                      'Scan & Translate AI is a free app supported by advertising served by Google AdMob. AdMob may use your device advertising identifier (Advertising ID) to display and measure ads and to prevent fraud.\n'
                      '• We do not sell your personal data to advertisers.\n'
                      '• You may see personalized or non-personalized ads. You can opt out of personalized advertising at any time in your device settings (Android: Settings > Privacy > Ads > "Delete advertising ID") and in Google Ads Settings (adssettings.google.com).\n'
                      '• Google\'s data practices are governed by Google\'s Privacy Policy (policies.google.com/privacy).\n'
                      '• Where required by law, a consent dialog is shown before personalized ads are served.'
                    ),
                    _buildSection(
                      '8. Children\'s Privacy',
                      'Our service is not intended for children under 13. We do not knowingly collect information from children under 13. If we become aware that a child under 13 has provided us with personal information, we will take steps to delete it.'
                    ),
                    _buildSection(
                      '9. Changes to This Policy',
                      'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last Updated" date. You may be required to review and accept the updated policy before continuing to use the app.'
                    ),
                    _buildSection(
                      '10. Contact Us',
                      'If you have any questions about this Privacy Policy, please contact us at:\n'
                      'Email: ${AppConstants.supportEmail}\n'
                      'Website: ${AppConstants.privacyPolicyUrl}'
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (widget.isMandatory)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkSurface
                      : AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Semantics(
                        label: 'Agree to privacy policy checkbox',
                        child: InkWell(
                          onTap: () {
                            HapticUtils.lightImpact();
                            setState(() => _isChecked = !_isChecked);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Icon(
                                  _isChecked
                                      ? Icons.check_box_rounded
                                      : Icons.check_box_outline_blank_rounded,
                                  color: _isChecked
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'I have read and agree to the Privacy Policy.',
                                    style: AppTypography.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isChecked
                              ? () {
                                  HapticUtils.mediumImpact();
                                  authNotifier.acceptPrivacyPolicy(
                                    privacyState.currentVersion,
                                  );
                                  ref
                                      .read(privacyPolicyProvider.notifier)
                                      .accept(privacyState.currentVersion);
                                  Navigator.of(context).pushReplacementNamed('/home');
                                }
                              : null,
                          child: const Text('Accept & Continue'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Semantics(
        label: title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms & Conditions',
              style: AppTypography.headlineLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            _buildTermsSection(
              '1. Acceptance of Terms',
              'By downloading, installing, or using Scan & Translate AI, you agree to be bound by these Terms & Conditions. If you do not agree to these terms, do not use the application.',
            ),
            _buildTermsSection(
              '2. License',
              'We grant you a limited, non-exclusive, non-transferable license to use the application for personal, non-commercial purposes. You may not modify, reverse engineer, or distribute the application without our written consent.',
            ),
            _buildTermsSection(
              '3. User Responsibilities',
              'You are responsible for maintaining the confidentiality of your account credentials. You agree not to use the application for any unlawful purpose or in violation of any applicable laws or regulations.',
            ),
            _buildTermsSection(
              '4. Intellectual Property',
              'All intellectual property rights in the application, including but not limited to code, design, and branding, are owned by ScanTranslateAI. You may not reproduce, distribute, or create derivative works without permission.',
            ),
            _buildTermsSection(
              '5. Limitation of Liability',
              'The application is provided "as is" without warranties of any kind. We shall not be liable for any damages arising from the use or inability to use the application, including but not limited to data loss or service interruption.',
            ),
            _buildTermsSection(
              '6. Termination',
              'We reserve the right to terminate or suspend your access to the application at any time, with or without cause, including for violation of these terms.',
            ),
            _buildTermsSection(
              '7. Governing Law',
              'These terms shall be governed by and construed in accordance with applicable laws. Any disputes shall be resolved in the courts of the jurisdiction where the company is registered.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
