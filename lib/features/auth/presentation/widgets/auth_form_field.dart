import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

class AuthFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final bool isPassword, isEmail;
  final TextInputAction textInputAction;
  final Widget? prefixIcon;
  const AuthFormField({
    super.key, required this.controller, required this.label, this.validator,
    this.isPassword = false, this.isEmail = false,
    this.textInputAction = TextInputAction.next, this.prefixIcon,
  });
  @override
  State<AuthFormField> createState() => _AuthFormFieldState();
}

class _AuthFormFieldState extends State<AuthFormField> {
  bool _obscured = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscured : false,
      keyboardType: widget.isEmail ? TextInputType.emailAddress : TextInputType.text,
      textInputAction: widget.textInputAction,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      style: AppTypography.bodyLarge,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.isPassword ? IconButton(
          icon: Icon(_obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          onPressed: () => setState(() => _obscured = !_obscured),
        ) : null,
      ),
      validator: widget.validator,
    );
  }
}
