import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HapticUtils {
  HapticUtils._();

  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  static void success() {
    HapticFeedback.heavyImpact();
  }

  static void error() {
    HapticFeedback.mediumImpact();
  }
}
