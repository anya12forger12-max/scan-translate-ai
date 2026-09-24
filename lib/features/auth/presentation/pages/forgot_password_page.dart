import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form_field.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailC = TextEditingController();
  bool _sent = false;

  @override
  void dispose() { _emailC.dispose(); super.dispose(); }

  void _reset() {
    if (_formKey.currentState!.validate()) {
      HapticUtils.mediumImpact();
      ref.read(authProvider.notifier).sendPasswordResetEmail(_emailC.text.trim());
      setState(() => _sent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(authProvider);
    final loading = s.status == AuthStatus.loading;
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Icon(Icons.lock_reset_rounded, size: 80, color: AppColors.primary),
                const SizedBox(height: 24),
                Text('Forgot Password?', style: AppTypography.headlineMedium, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Enter your email to receive a reset link.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                if (!_sent) ...[
                  AuthFormField(controller: _emailC, label: 'Email', isEmail: true, prefixIcon: const Icon(Icons.email_outlined)),
                  const SizedBox(height: 24),
                  SizedBox(height: 56, child: ElevatedButton(
                    onPressed: loading ? null : _reset,
                    child: loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Send Reset Link'))),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                    child: Column(children: [
                      const Icon(Icons.check_circle, size: 64, color: AppColors.success),
                      const SizedBox(height: 16),
                      Text('Email Sent!', style: AppTypography.headlineSmall.copyWith(color: AppColors.success)),
                      const SizedBox(height: 8),
                      Text('Check your email for the reset link.',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(height: 56, child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Back to Sign In'))),
                ],
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
