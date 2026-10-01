import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scan_translate_ai/features/translation/presentation/pages/text_translation_page.dart';
import 'package:scan_translate_ai/features/translation/presentation/providers/translation_provider.dart';

/// Regression tests for the "tapping Translate on empty input silently does
/// nothing" defect.
///
/// Both handlers started with `if (text.trim().isEmpty) return;`, so the
/// visible Translate button was tappable but produced no state change, no
/// error and no message — indistinguishable from a dead button on device.
/// Empty text is a *user* input error here, so it must be surfaced.
void main() {
  Future<void> pumpTextPage(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: TextTranslationPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Text Translation: empty input reports a message and stays idle',
      (tester) async {
    final container = ProviderContainer();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ProviderScope(
          child: MaterialApp(home: TextTranslationPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Translate'), findsOneWidget);
    await tester.tap(find.text('Translate'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // The user is told what is wrong instead of nothing happening.
    expect(
      find.text('Enter some text to translate.'),
      findsOneWidget,
      reason: 'empty input must be surfaced, not silently ignored',
    );
    // And no bogus translation was requested or shown.
    expect(find.text('Translating...'), findsNothing);
    final status = container.read(translationProvider).status;
    expect(status, isNot(TranslationStatus.loading));
    expect(status, isNot(TranslationStatus.success));

    container.dispose();
  });

  testWidgets(
      'Text Translation: whitespace-only input is also treated as empty',
      (tester) async {
    await pumpTextPage(tester);
    await tester.enterText(find.byType(TextField), '   \n  ');
    await tester.tap(find.text('Translate'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Enter some text to translate.'), findsOneWidget);
    expect(find.text('Translating...'), findsNothing);
  });

  testWidgets('Text Translation: the clear button appears while text is typed',
      (tester) async {
    // The suffix icon is decided by the input's own content, so the widget has
    // to rebuild as the user types; without the listener the icon only ever
    // reflected whatever the text was at some unrelated rebuild.
    await pumpTextPage(tester);
    expect(find.byIcon(Icons.clear), findsNothing);

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();
    expect(
      find.byIcon(Icons.clear),
      findsOneWidget,
      reason: 'clear button must appear once there is text to clear',
    );

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.clear), findsNothing);
  });
}
