import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

class AuthFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final bool isPassword;
  final bool isEmail;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefixIcon;
  final String? semanticLabel;

  const AuthFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.isPassword = false,
    this.isEmail = false,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.prefixIcon,
    this.semanticLabel,
  });

  @override
  State<AuthFormField> createState() => _AuthFormFieldState();
}

class _AuthFormFieldState extends State<AuthFormField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel ?? widget.label,
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscured : false,
        keyboardType: widget.isEmail ? TextInputType.emailAddress : TextInputType.text,
        textInputAction: widget.textInputAction,
        textCapitalization: TextCapitalization.none,
        autocorrect: false,
        enableSuggestions: !widget.isPassword,
        style: AppTypography.bodyLarge,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  ),
                  onPressed: () => setState(() => _obscured = !_obscured),
                  tooltip: _obscured ? 'Show password' : 'Hide password',
                )
              : null,
        ),
        validator: widget.validator,
        onFieldSubmitted: widget.onSubmitted,
      ),
    );
  }
}
