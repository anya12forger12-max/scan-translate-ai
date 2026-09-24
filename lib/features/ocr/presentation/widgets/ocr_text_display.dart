import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class OcrTextDisplay extends StatelessWidget {
  final String text;
  final String? detectedLanguage;
  final VoidCallback? onTranslate, onShare;
  const OcrTextDisplay({super.key, required this.text, this.detectedLanguage, this.onTranslate, this.onShare});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.ocrColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Text('OCR Result', style: AppTypography.labelMedium.copyWith(color: AppColors.ocrColor))),
          if (detectedLanguage != null) ...[
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(detectedLanguage!.toUpperCase(), style: AppTypography.labelMedium.copyWith(color: AppColors.info))),
          ],
        ]),
        const SizedBox(height: 16),
        Container(width: double.infinity, padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBackground : AppColors.background,
            borderRadius: BorderRadius.circular(12)),
          constraints: const BoxConstraints(maxHeight: 300),
          child: SingleChildScrollView(child: SelectableText(text, style: AppTypography.bodyLarge.copyWith(height: 1.6)))),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _chip(Icons.copy_rounded, 'Copy', () { Clipboard.setData(ClipboardData(text: text)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied'))); }),
          if (onTranslate != null) _chip(Icons.translate_rounded, 'Translate', onTranslate!),
          if (onShare != null) _chip(Icons.share_rounded, 'Share', onShare!),
        ]),
      ]),
    );
  }

  Widget _chip(IconData icon, String label, VoidCallback onTap) => Semantics(
    label: label, child: Material(color: Colors.transparent, child: InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(12),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 18, color: AppColors.primary), const SizedBox(width: 4),
          Text(label, style: AppTypography.labelMedium.copyWith(color: AppColors.primary))])),
    )),
  );
}
