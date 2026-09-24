import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class UserSettings extends Equatable {
  final bool darkMode;
  final bool hapticFeedback;
  final bool soundEnabled;
  final String defaultTargetLanguage;
  final bool autoSaveHistory;
  final bool highContrastMode;
  final double fontSizeScale;

  const UserSettings({
    this.darkMode = false,
    this.hapticFeedback = true,
    this.soundEnabled = true,
    this.defaultTargetLanguage = 'en',
    this.autoSaveHistory = true,
    this.highContrastMode = false,
    this.fontSizeScale = 1.0,
  });

  ThemeMode get materialThemeMode => darkMode ? ThemeMode.dark : ThemeMode.light;

  UserSettings copyWith({bool? darkMode, bool? hapticFeedback, bool? soundEnabled,
    String? defaultTargetLanguage, bool? autoSaveHistory, bool? highContrastMode, double? fontSizeScale}) =>
    UserSettings(darkMode: darkMode ?? this.darkMode, hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      soundEnabled: soundEnabled ?? this.soundEnabled, defaultTargetLanguage: defaultTargetLanguage ?? this.defaultTargetLanguage,
      autoSaveHistory: autoSaveHistory ?? this.autoSaveHistory, highContrastMode: highContrastMode ?? this.highContrastMode,
      fontSizeScale: fontSizeScale ?? this.fontSizeScale);

  @override List<Object?> get props => [darkMode, hapticFeedback, soundEnabled, defaultTargetLanguage, autoSaveHistory, highContrastMode, fontSizeScale];
}
