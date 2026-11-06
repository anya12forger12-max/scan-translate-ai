import 'package:flutter_test/flutter_test.dart';

import 'package:scan_translate_ai/features/settings/presentation/providers/settings_provider.dart';

void main() {
  test('settings default dark mode is false', () {
    final notifier = SettingsNotifier();
    expect(notifier.state.darkMode, isFalse);
  });

  test('setDarkMode updates state', () {
    final notifier = SettingsNotifier();
    notifier.setDarkMode(true);
    expect(notifier.state.darkMode, isTrue);
    notifier.setDarkMode(false);
    expect(notifier.state.darkMode, isFalse);
  });
}
