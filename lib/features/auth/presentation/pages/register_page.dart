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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(authProvider.notifier).clearError();
      }
    });
  }

  void _handleBack() {
    ref.read(authProvider.notifier).clearError();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      HapticUtils.mediumImpact();
      await ref.read(authProvider.notifier).signUpWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
          );
      if (!mounted) return;
      if (ref.read(authProvider).status == AuthStatus.authenticated) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;
    final errorMessage = authState.errorMessage;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: _handleBack),
        title: Semantics(
          label: 'Create Account page',
          child: const Text('Create Account'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    label: 'Create your account heading',
                    child: Text(
                      'Create Account',
                      style: AppTypography.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    label: 'Subtitle for account creation',
                    child: Text(
                      'Fill in your details to get started',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondaryOf(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  AuthFormField(
                    controller: _nameController,
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.person_outlined),
                    semanticLabel: 'Full name input field',
                  ),
                  const SizedBox(height: 16),
                  AuthFormField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter your email',
                    isEmail: true,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.email_outlined),
                    semanticLabel: 'Email input field',
                  ),
                  const SizedBox(height: 16),
                  AuthFormField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Create a strong password',
                    isPassword: true,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    semanticLabel: 'Password input field',
                  ),
                  const SizedBox(height: 16),
                  AuthFormField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hint: 'Re-enter your password',
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleSignUp(),
                    prefixIcon: const Icon(Icons.lock_outlined),
                    semanticLabel: 'Confirm password input field',
                    validator: (value) => Validators.validateConfirmPassword(
                      value,
                      _passwordController.text,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Semantics(
                        label: 'Error message',
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            errorMessage,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.errorOf(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleSignUp,
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Create Account'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
