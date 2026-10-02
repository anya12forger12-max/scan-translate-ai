import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:scan_translate_ai/app/di/providers.dart';
import 'package:scan_translate_ai/features/translation/data/datasources/translation_datasource.dart';
import 'package:scan_translate_ai/features/translation/data/repositories/translation_repository_impl.dart';
import 'package:scan_translate_ai/features/translation/presentation/pages/voice_translation_page.dart';
import 'package:scan_translate_ai/features/translation/presentation/providers/translation_provider.dart';

/// Real datasource with only the two calls the page can make replaced.
///
/// `speechToTextConverter` reports an empty transcription, which is what the
/// platform returns when nothing intelligible was heard, and `translateText`
/// records any call so the test can prove none is made for empty input.
class _EmptyRecognitionDataSource extends TranslationRemoteDataSource {
  _EmptyRecognitionDataSource()
    : super(flutterTts: FlutterTts(), speechToText: stt.SpeechToText());

  int translateTextCalls = 0;

  @override
  Future<String> speechToTextConverter({String? language}) async => '';

  @override
  Future<Map<String, dynamic>> translateText({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    translateTextCalls++;
    return {
      'originalText': text,
      'translatedText': 'translated',
      'sourceLanguage': sourceLanguage ?? 'en',
      'targetLanguage': targetLanguage,
      'confidence': 1.0,
    };
  }
}

/// Direct coverage for the voice counterpart of the empty-input defect fixed in
/// the text page.
///
/// The recognizer can hand back an empty transcription, which reaches
/// `_translateText` both from the partial-results callback and from the
/// Translate button. If the empty case is not surfaced the user sees nothing at
/// all, which is indistinguishable from a dead control.
void main() {
  // permission_handler talks over this channel; answering at the channel
  // boundary keeps the test on the real plugin path without adding the
  // platform-interface package as a direct dependency.
  const permissionChannel = MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  );

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (call) async {
          switch (call.method) {
            case 'checkPermissionStatus':
              return 1; // PermissionStatus.granted
            case 'requestPermissions':
              final permissions = (call.arguments as List<dynamic>).cast<int>();
              return {for (final p in permissions) p: 1};
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
  });

  Future<(ProviderContainer, _EmptyRecognitionDataSource)> pumpPage(
    WidgetTester tester,
  ) async {
    final datasource = _EmptyRecognitionDataSource();
    final container = ProviderContainer(
      overrides: [
        translationRepositoryProvider.overrideWithValue(
          TranslationRepositoryImpl(remoteDataSource: datasource),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: VoiceTranslationPage()),
      ),
    );
    await tester.pumpAndSettle();
    return (container, datasource);
  }

  Finder micButton() => find.bySemanticsLabel(
    RegExp('Tap to start voice input|Listening for speech'),
  );

  testWidgets(
    'Voice Translation: empty recognition reports a message and requests nothing',
    (tester) async {
      final (container, datasource) = await pumpPage(tester);

      await tester.tap(micButton());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(
        find.text('No speech recognized. Record something first.'),
        findsOneWidget,
        reason: 'empty recognition must be surfaced, not silently ignored',
      );
      expect(
        datasource.translateTextCalls,
        0,
        reason: 'no translation may be requested for empty input',
      );
      final status = container.read(translationProvider).status;
      expect(status, isNot(TranslationStatus.loading));
      expect(status, isNot(TranslationStatus.success));

      container.dispose();
    },
  );

  testWidgets(
    'Voice Translation: empty recognition leaves no Translate button',
    (tester) async {
      final (container, _) = await pumpPage(tester);

      expect(find.text('Translate'), findsNothing);

      await tester.tap(micButton());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(
        find.text('Translate'),
        findsNothing,
        reason: 'with nothing recognized there is still nothing to translate',
      );

      container.dispose();
    },
  );
}
