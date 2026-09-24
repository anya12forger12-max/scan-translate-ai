import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/history_item.dart';

class HistoryCard extends StatelessWidget {
  final HistoryItem item;
  const HistoryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final icon = switch (item.type) { HistoryItemType.scan => Icons.qr_code_scanner, HistoryItemType.ocr => Icons.text_snippet, HistoryItemType.translation => Icons.translate };
    final color = switch (item.type) { HistoryItemType.scan => AppColors.qrColor, HistoryItemType.ocr => AppColors.ocrColor, HistoryItemType.translation => AppColors.translationColor };

    return Semantics(
      button: true,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: item.details != null ? () => _showDetails(context) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.title, style: AppTypography.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(item.subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
              ])),
              Text(_formatTime(item.timestamp), style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
            ]),
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) => showModalBottomSheet(
    context: context, builder: (ctx) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item.title, style: AppTypography.titleMedium),
        const SizedBox(height: 12),
        if (item.details != null) Text(item.details!, style: AppTypography.bodyMedium),
        const SizedBox(height: 8),
        Text(_formatTime(item.timestamp), style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
      ]),
    ),
  );

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.month}/${dt.day}';
  }
}
