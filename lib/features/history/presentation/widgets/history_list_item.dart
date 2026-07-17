import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/entities/history_item.dart';

class HistoryListItem extends StatelessWidget {
  final HistoryItem item;
  final VoidCallback? onTap;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onDelete;

  const HistoryListItem({
    super.key,
    required this.item,
    this.onTap,
    this.onToggleFavorite,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Semantics(
      label: '${item.scanType} scan result',
      hint: 'Tap to view details. ${item.isFavorite ? 'Favorited.' : ''}',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurface
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: item.isFavorite
                    ? Border.all(
                        color: AppColors.favoriteColor.withValues(alpha: 0.3),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  _ScanTypeIcon(scanType: item.scanType),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getTypeColor().withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.formatType.toUpperCase(),
                                style: AppTypography.labelSmall.copyWith(
                                  color: _getTypeColor(),
                                ),
                              ),
                            ),
                            if (item.isFavorite) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.favorite,
                                size: 14,
                                color: AppColors.favoriteColor,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.rawValue,
                          style: AppTypography.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(item.scannedAt),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) {
                      switch (value) {
                        case 'favorite':
                          HapticUtils.lightImpact();
                          onToggleFavorite?.call();
                        case 'delete':
                          HapticUtils.mediumImpact();
                          onDelete?.call();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'favorite',
                        child: Row(
                          children: [
                            Icon(
                              item.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 18,
                              color: AppColors.favoriteColor,
                            ),
                            const SizedBox(width: 8),
                            Text(item.isFavorite ? 'Unfavorite' : 'Favorite'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    return switch (item.scanType) {
      'qr' => AppColors.qrColor,
      'barcode' => AppColors.barcodeColor,
      'ocr' => AppColors.ocrColor,
      'translation' => AppColors.translationColor,
      _ => AppColors.textSecondary,
    };
  }
}

class _ScanTypeIcon extends StatelessWidget {
  final String scanType;

  const _ScanTypeIcon({required this.scanType});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (scanType) {
      case 'qr':
        icon = Icons.qr_code_rounded;
        color = AppColors.qrColor;
      case 'barcode':
        icon = Icons.view_column_rounded;
        color = AppColors.barcodeColor;
      case 'ocr':
        icon = Icons.text_snippet_rounded;
        color = AppColors.ocrColor;
      case 'translation':
        icon = Icons.translate_rounded;
        color = AppColors.translationColor;
      default:
        icon = Icons.document_scanner_rounded;
        color = AppColors.textSecondary;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
