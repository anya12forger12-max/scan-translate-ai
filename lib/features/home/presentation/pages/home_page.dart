import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/feature_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = ResponsiveUtils.isTablet(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  ResponsiveUtils.isMobile(context) ? 16 : 32,
                  20,
                  8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      label: 'Welcome message',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello,',
                                style: AppTypography.bodyLarge.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.displayName ?? 'User',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Semantics(
                            label: 'User profile picture',
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              backgroundImage: user?.photoUrl != null
                                  ? NetworkImage(user!.photoUrl!)
                                  : null,
                              child: user?.photoUrl == null
                                  ? Icon(
                                      Icons.person_rounded,
                                      color: AppColors.primary,
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Semantics(
                      label: 'App greeting',
                      child: Text(
                        'What would you like to do?',
                        style: AppTypography.headlineMedium.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Scan, translate, and explore',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveUtils.gridColumns(context),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: isTablet ? 1.1 : 0.95,
                ),
                delegate: SliverChildListDelegate([
                  FeatureCard(
                    icon: Icons.qr_code_scanner_rounded,
                    title: 'Scan QR',
                    subtitle: 'Scan QR codes',
                    color: AppColors.qrColor,
                    animationDelay: 0,
                    onTap: () => Navigator.pushNamed(context, '/qr-scanner'),
                  ),
                  FeatureCard(
                    icon: Icons.view_column_rounded,
                    title: 'Scan Barcode',
                    subtitle: 'Scan barcodes',
                    color: AppColors.barcodeColor,
                    animationDelay: 50,
                    onTap: () =>
                        Navigator.pushNamed(context, '/barcode-scanner'),
                  ),
                  FeatureCard(
                    icon: Icons.text_snippet_rounded,
                    title: 'OCR Text',
                    subtitle: 'Recognize text',
                    color: AppColors.ocrColor,
                    animationDelay: 100,
                    onTap: () => Navigator.pushNamed(context, '/ocr'),
                  ),
                  FeatureCard(
                    icon: Icons.translate_rounded,
                    title: 'Text Translate',
                    subtitle: 'Translate text',
                    color: AppColors.translationColor,
                    animationDelay: 150,
                    onTap: () => Navigator.pushNamed(context, '/translate'),
                  ),
                  FeatureCard(
                    icon: Icons.camera_alt_rounded,
                    title: 'Camera Translate',
                    subtitle: 'Translate from photo',
                    color: AppColors.secondary,
                    animationDelay: 200,
                    onTap: () =>
                        Navigator.pushNamed(context, '/camera-translate'),
                  ),
                  FeatureCard(
                    icon: Icons.mic_rounded,
                    title: 'Voice Translate',
                    subtitle: 'Speak & translate',
                    color: AppColors.voiceColor,
                    animationDelay: 250,
                    onTap: () =>
                        Navigator.pushNamed(context, '/voice-translate'),
                  ),
                  FeatureCard(
                    icon: Icons.history_rounded,
                    title: 'Scan History',
                    subtitle: 'View past scans',
                    color: AppColors.historyColor,
                    animationDelay: 300,
                    onTap: () => Navigator.pushNamed(context, '/history'),
                  ),
                  FeatureCard(
                    icon: Icons.favorite_rounded,
                    title: 'Favorites',
                    subtitle: 'Saved items',
                    color: AppColors.favoriteColor,
                    animationDelay: 350,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Open history and filter by favorites')),
                      );
                      Navigator.pushNamed(context, '/history');
                    },
                  ),
                  FeatureCard(
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                    subtitle: 'App preferences',
                    color: AppColors.settingsColor,
                    animationDelay: 400,
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
