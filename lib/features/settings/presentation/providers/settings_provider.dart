import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_settings.dart';

class SettingsNotifier extends StateNotifier<UserSettings> {
  SettingsNotifier() : super(const UserSettings());

  void load(UserSettings s) => state = s;
  void setDarkMode(bool v) => state = state.copyWith(darkMode: v);
  void setHapticFeedback(bool v) => state = state.copyWith(hapticFeedback: v);
  void setSoundEnabled(bool v) => state = state.copyWith(soundEnabled: v);
  void setDefaultTargetLanguage(String v) => state = state.copyWith(defaultTargetLanguage: v);
  void setAutoSaveHistory(bool v) => state = state.copyWith(autoSaveHistory: v);
  void setHighContrastMode(bool v) => state = state.copyWith(highContrastMode: v);
  void setFontSizeScale(double v) => state = state.copyWith(fontSizeScale: v);
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, UserSettings>((ref) => SettingsNotifier());
