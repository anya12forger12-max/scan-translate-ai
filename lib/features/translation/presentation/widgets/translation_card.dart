import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/entities/translation_result.dart';

class TranslationCard extends StatelessWidget {
  final TranslationResult result;
  final VoidCallback? onTextToSpeech;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;

  const TranslationCard({
    super.key,
    required this.result,
    this.onTextToSpeech,
    this.onCopy,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          _TranslationBox(
            text: result.originalText,
            language: result.sourceLanguage,
            label: 'Original',
            backgroundColor: isDark
                ? AppColors.darkSurface
                : AppColors.surface,
            onCopy: () {
              Clipboard.setData(ClipboardData(text: result.originalText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Original text copied')),
              );
            },
            onTextToSpeech: null,
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Translation result',
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.secondary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Translated (${result.targetLanguage.toUpperCase()})',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (result.confidence > 0)
                        const SizedBox(width: 8),
                      if (result.confidence > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: result.confidence > 0.8
                                ? AppColors.success
                                : AppColors.warning,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(result.confidence * 100).toInt()}%',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.translatedText,
                    style: AppTypography.bodyLarge.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onTextToSpeech != null)
                        _IconButton(Icons.volume_up_rounded, 'Listen', onTextToSpeech!),
                      if (onCopy != null)
                        _IconButton(Icons.copy_rounded, 'Copy', onCopy!),
                      if (onShare != null)
                        _IconButton(Icons.share_rounded, 'Share', onShare!),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TranslationBox extends StatelessWidget {
  final String text;
  final String language;
  final String label;
  final Color backgroundColor;
  final VoidCallback? onCopy;
  final VoidCallback? onTextToSpeech;

  const _TranslationBox({
    required this.text,
    required this.language,
    required this.label,
    required this.backgroundColor,
    this.onCopy,
    this.onTextToSpeech,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$label (${language.toUpperCase()})',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: AppTypography.bodyLarge.copyWith(height: 1.6),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onCopy != null)
                _IconButton(Icons.copy_rounded, 'Copy', onCopy!),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _IconButton(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticUtils.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
