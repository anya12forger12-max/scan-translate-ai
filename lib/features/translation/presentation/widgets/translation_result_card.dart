import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/translation_result.dart';

class TranslationResultCard extends StatelessWidget {
  final TranslationResult result;
  final VoidCallback? onShare, onCopy;
  const TranslationResultCard({super.key, required this.result, this.onShare, this.onCopy});

  @override
  Widget build(BuildContext context) {
    final langName = _langName(result.targetLanguage);
    return Container(
      margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.translationColor.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.translationColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(langName, style: AppTypography.labelMedium.copyWith(color: AppColors.translationColor))),
        ]),
        const SizedBox(height: 16),
        Text(result.translatedText, style: AppTypography.headlineSmall.copyWith(height: 1.4)),
        const Divider(height: 32),
        Text(result.originalText, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.4)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _chip(Icons.copy_rounded, 'Copy', () { Clipboard.setData(ClipboardData(text: result.translatedText)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied'))); }),
          if (onShare != null) _chip(Icons.share_rounded, 'Share', onShare!),
        ]),
      ]),
    );
  }

  Widget _chip(IconData icon, String label, VoidCallback onTap) => Semantics(
    label: label, child: Material(color: Colors.transparent, child: InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(12),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 18, color: AppColors.translationColor), const SizedBox(width: 4),
          Text(label, style: AppTypography.labelMedium.copyWith(color: AppColors.translationColor))])),
    )),
  );

  String _langName(String code) {
    const m = {'en':'English','es':'Spanish','fr':'French','de':'German','it':'Italian','pt':'Portuguese','ru':'Russian','zh':'Chinese','ja':'Japanese','ko':'Korean','ar':'Arabic','hi':'Hindi'};
    return m[code] ?? code.toUpperCase();
  }
}
