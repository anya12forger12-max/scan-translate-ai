import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/scan_result.dart';

class ScanResultCard extends StatelessWidget {
  final ScanResult result;
  final VoidCallback? onShare, onOpen, onDismiss;
  const ScanResultCard({super.key, required this.result, this.onShare, this.onOpen, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(result.formatType.displayName, style: AppTypography.labelMedium.copyWith(color: AppColors.primary))),
          const Spacer(),
          if (onDismiss != null) IconButton(onPressed: onDismiss, icon: const Icon(Icons.close, size: 20)),
        ]),
        const SizedBox(height: 12),
        Container(width: double.infinity, padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBackground : AppColors.background,
            borderRadius: BorderRadius.circular(12)),
          child: SelectableText(result.rawValue, style: AppTypography.bodyMedium.copyWith(fontFamily: 'monospace'))),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _btn(Icons.copy_rounded, 'Copy', () {
            Clipboard.setData(ClipboardData(text: result.rawValue));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied')));
          }),
          if (onShare != null) _btn(Icons.share_rounded, 'Share', onShare!),
          if (result.decodedUrl != null && onOpen != null) _btn(Icons.open_in_new_rounded, 'Open', onOpen!),
        ]),
      ]),
    );
  }

  Widget _btn(IconData icon, String label, VoidCallback onTap) => Semantics(
    label: label, child: InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(12),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(children: [Icon(icon, color: AppColors.primary, size: 22), const SizedBox(height: 4),
          Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.primary))])),
    ),
  );
}
