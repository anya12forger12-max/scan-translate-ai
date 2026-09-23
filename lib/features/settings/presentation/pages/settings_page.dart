import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_tile.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String? _version;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _version = info.version);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
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
                      child: user.photoUrl != null
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: user.photoUrl!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                ),
                                errorWidget: (_, _, _) => const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : Icon(Icons.person, color: AppColors.primaryOf(context)),
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
                              color: AppColors.textSecondaryOf(context),
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
          const _SectionHeader(title: 'Appearance'),
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
          const _SectionHeader(title: 'Scanning'),
          SettingsSwitchTile(
            icon: Icons.save_outlined,
            title: 'Auto-save Scans',
            subtitle: 'Automatically save scan results to history',
            value: settings.autoSaveEnabled,
            onChanged: (_) =>
                ref.read(settingsProvider.notifier).toggleAutoSave(),
          ),

          const SizedBox(height: 16),
          const _SectionHeader(title: 'Account'),
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
            subtitle: 'Version ${_version ?? AppConstants.appVersion}',
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
                '${AppConstants.appName} v${_version ?? AppConstants.appVersion}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondaryOf(context),
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
        child: RadioGroup<AppThemeMode>(
          groupValue: current,
          onChanged: (value) {
            if (value != null) {
              ref.read(settingsProvider.notifier).setThemeMode(value);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Choose Theme', style: AppTypography.headlineSmall),
              const SizedBox(height: 16),
              const RadioListTile<AppThemeMode>(
                title: Text('Light'),
                secondary: Icon(Icons.light_mode),
                value: AppThemeMode.light,
              ),
              const RadioListTile<AppThemeMode>(
                title: Text('Dark'),
                secondary: Icon(Icons.dark_mode),
                value: AppThemeMode.dark,
              ),
              const RadioListTile<AppThemeMode>(
                title: Text('Follow System'),
                secondary: Icon(Icons.settings_brightness),
                value: AppThemeMode.system,
              ),
            ],
          ),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorOf(context)),
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
      applicationVersion: _version ?? AppConstants.appVersion,
      applicationIcon: Icon(Icons.translate_rounded, size: 48, color: AppColors.primaryOf(context)),
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
