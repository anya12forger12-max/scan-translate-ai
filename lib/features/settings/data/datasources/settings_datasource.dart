import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_settings.dart';

class SettingsLocalDataSource {
  static const _key = 'user_settings';

  Future<UserSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) {
      final fb = await _fromFirebase(await _firestoreLoad());
      if (fb != null) return fb;
      return const UserSettings();
    }
    return UserSettings(
      darkMode: (jsonDecode(json) as Map)['darkMode'] as bool? ?? false,
      hapticFeedback: (jsonDecode(json) as Map)['hapticFeedback'] as bool? ?? true,
      soundEnabled: (jsonDecode(json) as Map)['soundEnabled'] as bool? ?? true,
      defaultTargetLanguage: (jsonDecode(json) as Map)['defaultTargetLanguage'] as String? ?? 'en',
      autoSaveHistory: (jsonDecode(json) as Map)['autoSaveHistory'] as bool? ?? true,
      highContrastMode: (jsonDecode(json) as Map)['highContrastMode'] as bool? ?? false,
      fontSizeScale: ((jsonDecode(json) as Map)['fontSizeScale'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Future<void> saveSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode({
      'darkMode': settings.darkMode, 'hapticFeedback': settings.hapticFeedback,
      'soundEnabled': settings.soundEnabled, 'defaultTargetLanguage': settings.defaultTargetLanguage,
      'autoSaveHistory': settings.autoSaveHistory, 'highContrastMode': settings.highContrastMode,
      'fontSizeScale': settings.fontSizeScale,
    }));
    await _firestoreSave(settings);
  }

  Future<UserSettings?> _fromFirebase(Map<String, dynamic>? data) async {
    if (data == null) return null;
    return UserSettings(
      darkMode: data['darkMode'] as bool? ?? false,
      hapticFeedback: data['hapticFeedback'] as bool? ?? true,
      soundEnabled: data['soundEnabled'] as bool? ?? true,
      defaultTargetLanguage: data['defaultTargetLanguage'] as String? ?? 'en',
      autoSaveHistory: data['autoSaveHistory'] as bool? ?? true,
      highContrastMode: data['highContrastMode'] as bool? ?? false,
      fontSizeScale: (data['fontSizeScale'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Future<Map<String, dynamic>?> _firestoreLoad() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).collection('settings').doc('preferences').get();
      return doc.data();
    } catch (_) { return null; }
  }

  Future<void> _firestoreSave(UserSettings settings) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await FirebaseFirestore.instance.collection('users').doc(uid).collection('settings').doc('preferences').set({
        'darkMode': settings.darkMode, 'hapticFeedback': settings.hapticFeedback,
        'soundEnabled': settings.soundEnabled, 'defaultTargetLanguage': settings.defaultTargetLanguage,
        'autoSaveHistory': settings.autoSaveHistory, 'highContrastMode': settings.highContrastMode,
        'fontSizeScale': settings.fontSizeScale, 'updatedAt': Timestamp.now(),
      });
    } catch (_) {}
  }
}
