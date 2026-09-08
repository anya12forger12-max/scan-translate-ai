import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccessibilityUtils {
  AccessibilityUtils._();

  static SemanticsLabel accessibilityLabel({
    required String label,
    String? hint,
    String? value,
  }) {
    return SemanticsLabel(label: label, hint: hint, value: value);
  }
}

class SemanticsLabel {
  final String label;
  final String? hint;
  final String? value;

  const SemanticsLabel({
    required this.label,
    this.hint,
    this.value,
  });
}
