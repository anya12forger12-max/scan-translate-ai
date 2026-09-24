import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/widgets/loading_display.dart';
import '../providers/translation_provider.dart';
import '../widgets/language_selector.dart';
import '../widgets/translation_result_card.dart';

class VoiceTranslationPage extends ConsumerStatefulWidget {
  const VoiceTranslationPage({super.key});
  @override ConsumerState<VoiceTranslationPage> createState() => _VoiceTranslationPageState();
}

class _VoiceTranslationPageState extends ConsumerState<VoiceTranslationPage> {
  @override
  Widget build(BuildContext context) {
    final ts = ref.watch(translationProvider);
    final n = ref.read(translationProvider.notifier);
    final repo = ref.read(translationRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Voice Translate')),
      body: SingleChildScrollView(
        child: Column(children: [
          const SizedBox(height: 16),
          LanguageSelector(
            sourceLang: ts.sourceLang, targetLang: ts.targetLang,
            onSourceChanged: (l) => n.setSourceLang(l),
            onTargetChanged: (l) => n.setTargetLang(l),
          ),
          const SizedBox(height: 32),
          Icon(Icons.mic, size: 100, color: AppColors.voiceColor.withValues(alpha: 0.7)),
          const SizedBox(height: 16),
          Text('Tap to start speaking', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              n.setLoading();
              (await repo.translateFromVoice(to: ts.targetLang)).fold((f) => n.setError(f.message), (r) => n.setResult(r));
            },
            icon: const Icon(Icons.mic),
            label: const Text('Start Recording'),
          ),
          if (ts.status == TranslationStatus.loading) const Padding(padding: EdgeInsets.all(32), child: LoadingDisplay(message: 'Listening...')),
          if (ts.status == TranslationStatus.error) ErrorDisplay(message: ts.errorMessage ?? 'Failed.', actionLabel: 'Retry', onAction: () => n.reset()),
          if (ts.status == TranslationStatus.success && ts.result != null) TranslationResultCard(result: ts.result!),
        ]),
      ),
    );
  }
}
