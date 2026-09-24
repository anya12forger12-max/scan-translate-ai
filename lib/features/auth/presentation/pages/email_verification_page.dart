import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';

class EmailVerificationPage extends ConsumerWidget {
  const EmailVerificationPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.mark_email_unread_rounded, size: 80, color: AppColors.warning),
              const SizedBox(height: 24),
              Text('Verify Your Email', style: AppTypography.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text('Verification sent to:\n${user?.email ?? ''}\n\nPlease check your inbox.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              SizedBox(width: double.infinity, height: 56, child: ElevatedButton(
                onPressed: () {
                  ref.read(authProvider.notifier).sendEmailVerification();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification email sent!')));
                },
                child: const Text('Resend Verification Email'))),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, height: 56, child: TextButton(
                onPressed: () => ref.read(authProvider.notifier).signOut(),
                child: const Text('Sign Out'))),
            ]),
          ),
        ),
      ),
    );
  }
}
