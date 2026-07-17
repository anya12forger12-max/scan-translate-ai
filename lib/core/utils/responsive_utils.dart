import 'package:flutter/material.dart';

class ResponsiveUtils {
  ResponsiveUtils._();

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static int gridColumns(BuildContext context) {
    final width = screenWidth(context);
    if (width < 600) return 2;
    if (width < 900) return 3;
    if (width < 1200) return 4;
    return 6;
  }

  static double cardWidth(BuildContext context) {
    final width = screenWidth(context);
    if (width < 600) return (width - 48) / 2;
    if (width < 900) return (width - 64) / 3;
    return (width - 80) / 4;
  }

  static EdgeInsets screenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
    return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
  }

  static double getScaleFactor(BuildContext context) {
    final width = screenWidth(context);
    if (width < 360) return 0.8;
    if (width < 600) return 1.0;
    if (width < 900) return 1.2;
    return 1.4;
  }
}
