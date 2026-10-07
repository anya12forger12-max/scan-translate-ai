import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class HistoryFilter extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String?> onTypeChanged;
  final bool favoritesOnly;
  final ValueChanged<bool>? onFavoritesChanged;

  const HistoryFilter({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    this.favoritesOnly = false,
    this.onFavoritesChanged,
  });

  static const filters = <String?, String>{
    null: 'All',
    'qr': 'QR',
    'barcode': 'Barcode',
    'ocr': 'OCR',
    'translation': 'Translation',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (onFavoritesChanged != null)
            _buildChip(
              context,
              label: 'Favorites',
              semanticsLabel: 'Show favorites only',
              isSelected: favoritesOnly,
              onSelected: onFavoritesChanged!,
              leadingIcon: Icons.favorite_rounded,
            ),
          for (final entry in filters.entries)
            _buildChip(
              context,
              label: entry.value,
              semanticsLabel: 'Filter by ${entry.value}',
              isSelected: selectedType == entry.key,
              onSelected: (_) => onTypeChanged(entry.key),
            ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required String semanticsLabel,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
    IconData? leadingIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Semantics(
        label: semanticsLabel,
        selected: isSelected,
        child: FilterChip(
          avatar: leadingIcon == null
              ? null
              : Icon(
                  leadingIcon,
                  size: 16,
                  color: isSelected ? Colors.white : AppColors.favoriteColor,
                ),
          label: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
          selected: isSelected,
          onSelected: onSelected,
          selectedColor: AppColors.primary,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurface
              : AppColors.surface,
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected
                ? BorderSide.none
                : BorderSide(
                    color: AppColors.textSecondary.withValues(alpha: 0.2),
                  ),
          ),
        ),
      ),
    );
  }
}
