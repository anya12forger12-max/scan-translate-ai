import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scan_translate_ai/core/widgets/error_display.dart';
import 'package:scan_translate_ai/features/ocr/presentation/providers/ocr_provider.dart';
import 'package:scan_translate_ai/features/translation/presentation/pages/camera_translation_page.dart';
import 'package:scan_translate_ai/features/translation/presentation/pages/text_translation_page.dart';
import 'package:scan_translate_ai/features/translation/presentation/pages/voice_translation_page.dart';
import 'package:scan_translate_ai/features/translation/presentation/providers/translation_provider.dart';

void main() {
  Widget wrap(ProviderContainer container, Widget page) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: page),
    );
  }

  testWidgets('camera capture failures show only on the camera page and '
      'never pollute the shared translation state', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(wrap(container, const CameraTranslationPage()));
    await tester.pump();

    final ocrNotifier = container.read(ocrProvider.notifier);
    ocrNotifier.setError('Camera access denied');
    await tester.pump();

    expect(find.byType(ErrorDisplay), findsOneWidget);
    expect(find.text('Camera access denied'), findsOneWidget);
    expect(
      container.read(translationProvider).status,
      TranslationStatus.initial,
      reason: 'A camera/gallery capture failure is a page-local concern and '
          'must not leak into the shared translationProvider.',
    );

    // Leaving the page and opening another translation screen must be clean.
    await tester.pumpWidget(wrap(container, const VoiceTranslationPage()));
    await tester.pump();
    expect(find.byType(ErrorDisplay), findsNothing);

    await tester.pumpWidget(wrap(container, const TextTranslationPage()));
    await tester.pump();
    expect(find.byType(ErrorDisplay), findsNothing);
  });

  testWidgets('a fresh translation page never surfaces a stale error left by '
      'an earlier screen', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(translationProvider.notifier).setError('stale error');

    await tester.pumpWidget(wrap(container, const VoiceTranslationPage()));
    await tester.pump();
    expect(find.byType(ErrorDisplay), findsNothing);

    await tester.pumpWidget(wrap(container, const CameraTranslationPage()));
    await tester.pump();
    expect(find.byType(ErrorDisplay), findsNothing);

    await tester.pumpWidget(wrap(container, const TextTranslationPage()));
    await tester.pump();
    expect(find.byType(ErrorDisplay), findsNothing);
  });
}