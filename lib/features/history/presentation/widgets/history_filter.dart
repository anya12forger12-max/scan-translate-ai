import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class HistoryFilter extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String?> onTypeChanged;

  const HistoryFilter({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
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
        children: filters.entries.map((entry) {
          final isSelected = selectedType == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Semantics(
              label: 'Filter by ${entry.value}',
              selected: isSelected,
              child: FilterChip(
                label: Text(
                  entry.value!,
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => onTypeChanged(entry.key),
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
        }).toList(),
      ),
    );
  }
}
