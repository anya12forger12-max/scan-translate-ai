import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class SettingsState {
  final AppThemeMode themeMode;
  final String locale;
  final bool hapticFeedbackEnabled;
  final bool soundEnabled;
  final bool autoSaveEnabled;

  const SettingsState({
    this.themeMode = AppThemeMode.system,
    this.locale = 'en',
    this.hapticFeedbackEnabled = true,
    this.soundEnabled = true,
    this.autoSaveEnabled = true,
  });

  SettingsState copyWith({
    AppThemeMode? themeMode,
    String? locale,
    bool? hapticFeedbackEnabled,
    bool? soundEnabled,
    bool? autoSaveEnabled,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      hapticFeedbackEnabled:
          hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      autoSaveEnabled: autoSaveEnabled ?? this.autoSaveEnabled,
    );
  }

  ThemeMode get materialThemeMode {
    return switch (themeMode) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.system => ThemeMode.system,
    };
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeStr = prefs.getString('themeMode') ?? 'system';
    state = state.copyWith(
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == themeModeStr,
        orElse: () => AppThemeMode.system,
      ),
      locale: prefs.getString('locale') ?? 'en',
      hapticFeedbackEnabled: prefs.getBool('hapticFeedback') ?? true,
      soundEnabled: prefs.getBool('soundEnabled') ?? true,
      autoSaveEnabled: prefs.getBool('autoSaveEnabled') ?? true,
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
  }

  Future<void> setLocale(String locale) async {
    state = state.copyWith(locale: locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale);
  }

  Future<void> toggleHapticFeedback() async {
    state = state.copyWith(hapticFeedbackEnabled: !state.hapticFeedbackEnabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hapticFeedback', state.hapticFeedbackEnabled);
  }

  Future<void> toggleSound() async {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', state.soundEnabled);
  }

  Future<void> toggleAutoSave() async {
    state = state.copyWith(autoSaveEnabled: !state.autoSaveEnabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoSaveEnabled', state.autoSaveEnabled);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
