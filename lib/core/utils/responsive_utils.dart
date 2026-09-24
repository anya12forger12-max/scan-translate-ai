import 'package:flutter/material.dart';

class ResponsiveUtils {
  ResponsiveUtils._();
  static bool isMobile(BuildContext c) => MediaQuery.of(c).size.width < 600;
  static bool isTablet(BuildContext c) =>
      MediaQuery.of(c).size.width >= 600 && MediaQuery.of(c).size.width < 1200;
  static double screenWidth(BuildContext c) => MediaQuery.of(c).size.width;
  static int gridColumns(BuildContext c) {
    final w = screenWidth(c);
    if (w < 600) return 2;
    if (w < 900) return 3;
    if (w < 1200) return 4;
    return 6;
  }
}
