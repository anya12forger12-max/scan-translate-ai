import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../app/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final repo = ref.read(settingsRepositoryProvider);

    void save() => repo.saveSettings(s);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(children: [
        const _SectionHeader(title: 'Appearance'),
        SwitchListTile(title: const Text('Dark Mode'), subtitle: const Text('Toggle dark theme'),
          value: s.darkMode, onChanged: (v) { n.setDarkMode(v); HapticUtils.lightImpact(); save(); }),
        SwitchListTile(title: const Text('High Contrast Mode'), subtitle: const Text('Enhanced accessibility'),
          value: s.highContrastMode, onChanged: (v) { n.setHighContrastMode(v); save(); }),
        ListTile(title: const Text('Font Size'), subtitle: Text('${(s.fontSizeScale * 100).round()}%'),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(onPressed: () { if (s.fontSizeScale > 0.7) { n.setFontSizeScale((s.fontSizeScale - 0.1).clamp(0.5, 1.5)); save(); } },
              icon: const Icon(Icons.remove_circle_outline)),
            IconButton(onPressed: () { if (s.fontSizeScale < 1.5) { n.setFontSizeScale((s.fontSizeScale + 0.1).clamp(0.5, 1.5)); save(); } },
              icon: const Icon(Icons.add_circle_outline)),
          ]),
        ),
        const Divider(),
        const _SectionHeader(title: 'Preferences'),
        SwitchListTile(title: const Text('Haptic Feedback'), subtitle: const Text('Vibration on interactions'),
          value: s.hapticFeedback, onChanged: (v) { n.setHapticFeedback(v); save(); }),
        SwitchListTile(title: const Text('Sound Effects'), subtitle: const Text('Audio feedback'),
          value: s.soundEnabled, onChanged: (v) { n.setSoundEnabled(v); save(); }),
        SwitchListTile(title: const Text('Auto-save History'), subtitle: const Text('Save scans & translations'),
          value: s.autoSaveHistory, onChanged: (v) { n.setAutoSaveHistory(v); save(); }),
        const Divider(),
        const _SectionHeader(title: 'Account'),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          onTap: () async {
            HapticUtils.warning();
            final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
              title: const Text('Sign Out'), content: const Text('Are you sure?'),
              actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sign Out', style: TextStyle(color: Colors.red)))],
            ));
            if (confirm == true) { await FirebaseAuth.instance.signOut(); if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false); }
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
          onTap: () async => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact support to delete your account.'))),
        ),
        const Divider(),
        const _SectionHeader(title: 'About'),
        ListTile(title: const Text('Version'), trailing: Text('1.0.0', style: AppTypography.bodyMedium)),
        ListTile(title: const Text('Privacy Policy'), trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, '/privacy')),
        const SizedBox(height: 32),
      ]),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(title, style: AppTypography.titleSmall.copyWith(color: AppColors.primary)),
  );
}
