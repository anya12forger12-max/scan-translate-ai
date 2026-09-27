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
  });
}
