import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('main.dart error handler', () {
    test(
        'PlatformDispatcher.instance.onError records platform errors as non-fatal',
        () async {
      // Platform errors (camera, sensor, permission) are often recoverable.
      // Marking them fatal inflates the Play Console crash-free metric and
      // makes genuine crashes harder to find. The handler must use fatal: false.
      final src = await File('lib/main.dart').readAsString();
      expect(src, contains('fatal: false'));
      expect(src, isNot(contains('fatal: true')));
    });

    test('datasource exception messages are user-friendly (no raw exception text)',
        () async {
      // Raw exception text (e.g. Google sign-in tokens) must not be embedded
      // in throw strings — it leaks PII into Crashlytics and logs.
      final libDir = Directory('lib');
      final dartFiles = libDir.listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();
      for (final f in dartFiles) {
        final src = await f.readAsString();
        // The pattern \${e.toString()} must not appear in any lib source.
        expect(
          src,
          isNot(contains(r'\${e.toString()}')),
          reason: '${f.path} still embeds raw exception text',
        );
      }
    });

    test('Crashlytics is only touched after Firebase.initializeApp', () async {
      // FirebaseCrashlytics.instance resolves Firebase.app() and throws
      // [core/no-app] before initializeApp has run, which crashed cold
      // launch on the v1.2.32 release build for every user. This guard
      // pins the source ordering so the call can never move back above
      // initialization.
      final src = await File('lib/main.dart').readAsString();
      final initIndex = src.indexOf('Firebase.initializeApp()');
      final crashlyticsIndex =
          src.indexOf('FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled');
      expect(initIndex, greaterThan(-1),
          reason: 'Firebase.initializeApp() must be called in main()');
      expect(crashlyticsIndex, greaterThan(-1),
          reason: 'Crashlytics enable call is missing from main()');
      expect(crashlyticsIndex, greaterThan(initIndex),
          reason:
              'Crashlytics is touched at offset $crashlyticsIndex before '
              'Firebase.initializeApp() at $initIndex — cold launch throws '
              '[core/no-app]');
    });
  });
}
