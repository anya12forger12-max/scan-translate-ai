import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Poppins and Inter are bundled in assets/fonts and declared in
  // pubspec.yaml, so no runtime fetch is needed or wanted. Disabling it
  // turns a missing bundled face into a loud error instead of a silent
  // fallback to the platform font.
  GoogleFonts.config.allowRuntimeFetching = false;

  bool firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  FlutterError.onError = (errorDetails) {
    if (firebaseReady) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    } else {
      FlutterError.dumpErrorToConsole(errorDetails);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    // Platform errors (camera, sensor, permission) are often recoverable.
    // Record them so they are visible in Crashlytics, but do NOT mark them
    // as fatal — doing so would count every recoverable platform failure as
    // a crash in the Play Console and inflate the crash-free metric.
    if (firebaseReady) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
    }
    return true;
  };

  final container = ProviderContainer(overrides: []);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ScanTranslateApp(),
    ),
  );
}
