import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Test-wide setup: load the bundled fonts before any test body runs.
///
/// Flutter 3.50 verifies that no frame callbacks are left over after a widget
/// test finishes. Loading a font enqueues a `fontsChange` system message and a
/// relayout callback; when that happens during the first test in a file, the
/// callback can land after teardown and fail an otherwise valid test. Warming
/// the two families used by the app here keeps font loading out of test bodies.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  for (final family in [GoogleFonts.poppins, GoogleFonts.inter]) {
    for (final weight in [
      FontWeight.w400,
      FontWeight.w500,
      FontWeight.w600,
      FontWeight.bold,
    ]) {
      family(fontWeight: weight);
    }
  }
  await GoogleFonts.pendingFonts();
  await testMain();
}
