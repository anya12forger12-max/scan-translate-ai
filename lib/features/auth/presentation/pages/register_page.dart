import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form_field.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});
  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _pwC = TextEditingController();
  final _cpwC = TextEditingController();

  @override
  void dispose() { _nameC.dispose(); _emailC.dispose(); _pwC.dispose(); _cpwC.dispose(); super.dispose(); }

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      HapticUtils.mediumImpact();
      ref.read(authProvider.notifier).signUpWithEmail(_emailC.text.trim(), _pwC.text, _nameC.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(authProvider);
    final loading = s.status == AuthStatus.loading;
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SizedBox(height: 16),
              Text('Create Account', style: AppTypography.headlineMedium),
              const SizedBox(height: 8),
              Text('Fill in your details to get started',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              AuthFormField(controller: _nameC, label: 'Full Name', prefixIcon: const Icon(Icons.person_outlined)),
              const SizedBox(height: 16),
              AuthFormField(controller: _emailC, label: 'Email', isEmail: true, prefixIcon: const Icon(Icons.email_outlined)),
              const SizedBox(height: 16),
              AuthFormField(controller: _pwC, label: 'Password', isPassword: true, prefixIcon: const Icon(Icons.lock_outlined)),
              const SizedBox(height: 16),
              AuthFormField(controller: _cpwC, label: 'Confirm Password', isPassword: true,
                validator: (v) => Validators.confirmPassword(v, _pwC.text), prefixIcon: const Icon(Icons.lock_outlined)),
              const SizedBox(height: 24),
              if (s.errorMessage != null) Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(s.errorMessage!, style: AppTypography.bodyMedium.copyWith(color: AppColors.error), textAlign: TextAlign.center),
              ),
              const SizedBox(height: 16),
              SizedBox(height: 56, child: ElevatedButton(
                onPressed: loading ? null : _signUp,
                child: loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Create Account'))),
            ]),
          ),
        ),
      ),
    );
  }
}
