import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/entities/scan_result.dart';

class ScanResultCard extends StatelessWidget {
  final ScanResult result;
  final VoidCallback? onShare;
  final VoidCallback? onCopy;
  final VoidCallback? onOpen;
  final VoidCallback? onSave;
  final VoidCallback? onDismiss;

  const ScanResultCard({
    super.key,
    required this.result,
    this.onShare,
    this.onCopy,
    this.onOpen,
    this.onSave,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Scan result: ${result.formatType.displayName}',
      hint: 'Contains the decoded value from your scan',
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurface
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getTypeColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    result.formatType.displayName,
                    style: AppTypography.labelMedium.copyWith(
                      color: _getTypeColor(),
                    ),
                  ),
                ),
                const Spacer(),
                if (onDismiss != null)
                  IconButton(
                    onPressed: onDismiss,
                    icon: const Icon(Icons.close, size: 20),
                    tooltip: 'Dismiss',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBackground
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                result.rawValue,
                style: AppTypography.bodyMedium.copyWith(
                  fontFamily: 'monospace',
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.copy_rounded,
                  label: 'Copy',
                  onTap: () {
                    HapticUtils.lightImpact();
                    Clipboard.setData(ClipboardData(text: result.rawValue));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                ),
                if (onShare != null)
                  _ActionButton(
                    icon: Icons.share_rounded,
                    label: 'Share',
                    onTap: () {
                      HapticUtils.lightImpact();
                      onShare!();
                    },
                  ),
                if (result.decodedUrl != null && onOpen != null)
                  _ActionButton(
                    icon: Icons.open_in_new_rounded,
                    label: 'Open',
                    onTap: () {
                      HapticUtils.lightImpact();
                      onOpen!();
                    },
                  ),
                if (onSave != null)
                  _ActionButton(
                    icon: Icons.save_rounded,
                    label: 'Save',
                    onTap: () {
                      HapticUtils.lightImpact();
                      onSave!();
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor() {
    return switch (result.scanType) {
      ScanType.qr => AppColors.qrColor,
      ScanType.barcode => AppColors.barcodeColor,
      ScanType.ocr => AppColors.ocrColor,
      ScanType.translation => AppColors.translationColor,
    };
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: 'Tap to $label this content',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
