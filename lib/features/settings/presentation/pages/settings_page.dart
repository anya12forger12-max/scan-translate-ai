import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_tile.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (user != null)
            Semantics(
              label: 'User profile information',
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkSurface
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      backgroundImage: user.photoUrl != null
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: user.photoUrl == null
                          ? Icon(Icons.person, color: AppColors.primary)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName ?? 'User',
                            style: AppTypography.titleLarge,
                          ),
                          Text(
                            user.email,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),
          _SectionHeader(title: 'Appearance'),
          SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Theme',
            subtitle: _getThemeName(settings.themeMode),
            onTap: () => _showThemePicker(context, ref),
          ),
          SettingsSwitchTile(
            icon: Icons.vibration_outlined,
            title: 'Haptic Feedback',
            value: settings.hapticFeedbackEnabled,
            onChanged: (_) {
              HapticUtils.lightImpact();
              ref.read(settingsProvider.notifier).toggleHapticFeedback();
            },
          ),

          const SizedBox(height: 16),
          _SectionHeader(title: 'Scanning'),
          SettingsSwitchTile(
            icon: Icons.save_outlined,
            title: 'Auto-save Scans',
            subtitle: 'Automatically save scan results to history',
            value: settings.autoSaveEnabled,
            onChanged: (_) =>
                ref.read(settingsProvider.notifier).toggleAutoSave(),
          ),

          const SizedBox(height: 16),
          _SectionHeader(title: 'Account'),
          SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => Navigator.pushNamed(context, '/privacy-policy',
              arguments: {'mandatory': false},
            ),
          ),
          SettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            onTap: () => Navigator.pushNamed(context, '/terms'),
          ),
          SettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Version ${AppConstants.appVersion}',
            onTap: () => _showAboutDialog(context),
          ),
          SettingsTile(
            icon: Icons.mail_outline,
            title: 'Contact Us',
            subtitle: AppConstants.supportEmail,
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.delete_forever_outlined,
            title: 'Delete Account',
            iconColor: AppColors.error,
            onTap: () => _showDeleteAccountDialog(context, ref),
            showDivider: true,
          ),
          SettingsTile(
            icon: Icons.logout,
            title: 'Sign Out',
            iconColor: AppColors.error,
            onTap: () => _showSignOutDialog(context, ref),
            showDivider: false,
          ),

          const SizedBox(height: 32),
          Semantics(
            label: 'App version information',
            child: Center(
              child: Text(
                '${AppConstants.appName} v${AppConstants.appVersion}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _getThemeName(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.light => 'Light',
      AppThemeMode.dark => 'Dark',
      AppThemeMode.system => 'Follow System',
    };
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    final current = ref.read(settingsProvider).themeMode;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose Theme', style: AppTypography.headlineSmall),
            const SizedBox(height: 16),
            RadioListTile<AppThemeMode>(
              title: const Text('Light'),
              secondary: const Icon(Icons.light_mode),
              value: AppThemeMode.light,
              groupValue: current,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setThemeMode(AppThemeMode.light);
                Navigator.pop(context);
              },
            ),
            RadioListTile<AppThemeMode>(
              title: const Text('Dark'),
              secondary: const Icon(Icons.dark_mode),
              value: AppThemeMode.dark,
              groupValue: current,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setThemeMode(AppThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            RadioListTile<AppThemeMode>(
              title: const Text('Follow System'),
              secondary: const Icon(Icons.settings_brightness),
              value: AppThemeMode.system,
              groupValue: current,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setThemeMode(AppThemeMode.system);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action is permanent and cannot be undone. All your data will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).deleteAccount();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: const Icon(Icons.translate_rounded, size: 48, color: AppColors.primary),
      children: [
        const Text('Scan QR codes, barcodes, recognize text, and translate content with AI-powered technology.'),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        title,
        style: AppTypography.titleSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
