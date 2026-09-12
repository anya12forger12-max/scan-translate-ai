import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

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
    if (firebaseReady) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    }
    return false;
  };

  final container = ProviderContainer(overrides: []);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ScanTranslateApp(),
    ),
  );
}
