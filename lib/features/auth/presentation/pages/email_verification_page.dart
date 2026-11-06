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
    final userEmail = user?.email;
    Widget buildEmailWidget() {
      if (userEmail == null) {
        return Text(
          'No email associated with your account.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        );
      }
      return Text('Verification sent to:\n$userEmail\n\nPlease check your inbox.',
        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        textAlign: TextAlign.center,
      );
    }
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
              buildEmailWidget(),
              const SizedBox(height: 32),
              SizedBox(width: 400, height: 56, child: ElevatedButton(onPressed: () {}, child: const Text('Resend'))),
              const SizedBox(height: 16),
              SizedBox(width: 400, height: 56, child: TextButton(onPressed: () {}, child: const Text('Sign Out'))),
            ]),
          ),
        ),
      ),
    );
  }
}
