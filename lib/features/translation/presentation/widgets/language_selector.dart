import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/translation_result.dart';

class LanguageSelector extends StatelessWidget {
  final String selectedCode;
  final ValueChanged<String> onChanged;
  final String label;
  final List<Language>? languages;

  const LanguageSelector({
    super.key,
    required this.selectedCode,
    required this.onChanged,
    required this.label,
    this.languages,
  });

  @override
  Widget build(BuildContext context) {
    final items = languages ?? Language.supported;

    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurface
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedCode,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down_rounded),
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
            items: items.map((language) {
              return DropdownMenuItem<String>(
                value: language.code,
                child: Text(
                  '${language.nativeName ?? language.name} (${language.code.toUpperCase()})',
                  style: AppTypography.bodyMedium,
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null && value != selectedCode) {
                onChanged(value);
              }
            },
          ),
        ),
      ),
    );
  }
}

class LanguageSwapButton extends StatelessWidget {
  final VoidCallback onTap;

  const LanguageSwapButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Swap source and target languages',
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: onTap,
          icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
          tooltip: 'Swap languages',
        ),
      ),
    );
  }
}
