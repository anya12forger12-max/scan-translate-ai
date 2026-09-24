import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/widgets/loading_display.dart';
import '../providers/translation_provider.dart';
import '../widgets/language_selector.dart';
import '../widgets/translation_result_card.dart';

class TextTranslationPage extends ConsumerStatefulWidget {
  final String? initialText;
  const TextTranslationPage({super.key, this.initialText});
  @override ConsumerState<TextTranslationPage> createState() => _TextTranslationPageState();
}

class _TextTranslationPageState extends ConsumerState<TextTranslationPage> {
  final _ctrl = TextEditingController();
  @override void initState() { super.initState(); if (widget.initialText != null) _ctrl.text = widget.initialText!; }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final ts = ref.watch(translationProvider);
    final n = ref.read(translationProvider.notifier);
    final repo = ref.read(translationRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Translate'), actions: [
        IconButton(onPressed: () => n.swapLanguages(), icon: const Icon(Icons.swap_horiz)),
      ]),
      body: SingleChildScrollView(
        child: Column(children: [
          const SizedBox(height: 16),
          LanguageSelector(
            sourceLang: ts.sourceLang, targetLang: ts.targetLang,
            onSourceChanged: (l) => n.setSourceLang(l),
            onTargetChanged: (l) => n.setTargetLang(l),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.translationColor.withValues(alpha: 0.3)),
            ),
            child: TextField(
              controller: _ctrl,
              maxLines: 5, minLines: 3,
              style: AppTypography.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Enter text to translate...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(20),
                suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    icon: const Icon(Icons.mic),
                    onPressed: () async {
                      HapticUtils.mediumImpact(); n.setLoading();
                      (await repo.translateFromVoice(to: ts.targetLang)).fold((f) => n.setError(f.message), (r) => n.setResult(r));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.translate),
                    onPressed: () async {
                      if (_ctrl.text.trim().isEmpty) return;
                      HapticUtils.mediumImpact(); n.setLoading();
                      (await repo.translate(_ctrl.text.trim(), from: ts.sourceLang, to: ts.targetLang)).fold((f) => n.setError(f.message), (r) => n.setResult(r));
                    },
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (ts.status == TranslationStatus.loading) const LoadingDisplay(message: 'Translating...'),
          if (ts.status == TranslationStatus.error) ErrorDisplay(message: ts.errorMessage ?? 'Failed.', actionLabel: 'Retry', onAction: () => n.reset()),
          if (ts.status == TranslationStatus.success && ts.result != null) TranslationResultCard(
            result: ts.result!,
            onShare: () => Share.share('${ts.result!.originalText}\n→ ${ts.result!.translatedText}'),
            onCopy: () => _ctrl.text = ts.result!.translatedText,
          ),
        ]),
      ),
    );
  }
}
