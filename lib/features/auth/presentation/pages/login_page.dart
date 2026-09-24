import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailC = TextEditingController();
  final _pwC = TextEditingController();

  @override
  void dispose() { _emailC.dispose(); _pwC.dispose(); super.dispose(); }

  void _login() {
    if (_formKey.currentState!.validate()) {
      HapticUtils.mediumImpact();
      ref.read(authProvider.notifier).signInWithEmail(_emailC.text.trim(), _pwC.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(authProvider);
    final loading = s.status == AuthStatus.loading;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Semantics(label: 'App logo', child: const Icon(Icons.translate_rounded, size: 80, color: AppColors.primary)),
                const SizedBox(height: 16),
                Semantics(label: 'App title', child: Text('Scan & Translate AI', textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary))),
                const SizedBox(height: 8),
                Text('Scan, Translate, Simplify', textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 48),
                Text('Welcome Back', style: AppTypography.headlineMedium),
                const SizedBox(height: 24),
                AuthFormField(controller: _emailC, label: 'Email', isEmail: true, prefixIcon: const Icon(Icons.email_outlined)),
                const SizedBox(height: 16),
                AuthFormField(controller: _pwC, label: 'Password', isPassword: true, textInputAction: TextInputAction.done, prefixIcon: const Icon(Icons.lock_outlined)),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                  child: Text('Forgot Password?', style: AppTypography.labelLarge.copyWith(color: AppColors.primary)))),
                const SizedBox(height: 24),
                if (s.errorMessage != null) Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(s.errorMessage!, style: AppTypography.bodyMedium.copyWith(color: AppColors.error), textAlign: TextAlign.center),
                ),
                const SizedBox(height: 16),
                SizedBox(height: 56, child: ElevatedButton(
                  onPressed: loading ? null : _login,
                  child: loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Sign In'))),
                const SizedBox(height: 16),
                SizedBox(height: 56, child: OutlinedButton.icon(
                  onPressed: loading ? null : () => ref.read(authProvider.notifier).signInWithGoogle(),
                  icon: const Icon(Icons.g_mobiledata_rounded), label: const Text('Continue with Google'))),
                const SizedBox(height: 32),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Don't have an account? ", style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: const Text('Sign Up')),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
