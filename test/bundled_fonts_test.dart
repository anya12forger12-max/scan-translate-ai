import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() async {
    // Mirrors main(): fonts must come from the bundle, never the network.
    GoogleFonts.config.allowRuntimeFetching = false;
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  test('every GoogleFonts family used in lib/ is bundled', () async {
    final styles = <TextStyle>[
      GoogleFonts.poppins(),
      GoogleFonts.poppins(fontWeight: FontWeight.w500),
      GoogleFonts.poppins(fontWeight: FontWeight.w600),
      GoogleFonts.poppins(fontWeight: FontWeight.bold),
      GoogleFonts.inter(),
      GoogleFonts.inter(fontWeight: FontWeight.w500),
      GoogleFonts.inter(fontWeight: FontWeight.w600),
      GoogleFonts.inter(fontWeight: FontWeight.bold),
    ];
    for (final s in styles) {
      expect(s.fontFamily, isNotNull, reason: 'family must resolve');
    }
    // With runtime fetching disabled, a bundled face must load without error.
    // GoogleFonts.poppins()/inter() each enqueue a load; draining the
    // public queue proves the faces resolve with fetching disabled.
    await GoogleFonts.pendingFonts();
  });

  test('pubspec.yaml declares the bundled font assets', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final asset in [
      'assets/fonts/Poppins-Regular.ttf',
      'assets/fonts/Poppins-Medium.ttf',
      'assets/fonts/Poppins-SemiBold.ttf',
      'assets/fonts/Poppins-Bold.ttf',
      'assets/fonts/Inter-Regular.ttf',
      'assets/fonts/Inter-Medium.ttf',
      'assets/fonts/Inter-SemiBold.ttf',
      'assets/fonts/Inter-Bold.ttf',
    ]) {
      expect(pubspec, contains(asset), reason: '$asset must be declared');
      expect(
        File(asset).existsSync(),
        isTrue,
        reason: '$asset must exist on disk',
      );
    }
  });

  test('main() disables runtime font fetching', () {
    // The test sets the flag itself, so without this the removal of the
    // line from main.dart would go unnoticed and offline users would
    // silently get the platform font again.
    final main = File('lib/main.dart').readAsStringSync();
    expect(
      main,
      contains('GoogleFonts.config.allowRuntimeFetching = false'),
      reason: 'main() must disable runtime fetching so a missing bundled '
          'font fails loudly instead of falling back silently',
    );
  });
}
