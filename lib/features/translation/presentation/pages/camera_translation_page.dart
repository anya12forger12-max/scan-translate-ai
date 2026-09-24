import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_display.dart';
import '../../../ocr/presentation/providers/ocr_provider.dart';
import '../providers/translation_provider.dart';
import '../widgets/translation_result_card.dart';

class CameraTranslationPage extends ConsumerStatefulWidget {
  const CameraTranslationPage({super.key});
  @override ConsumerState<CameraTranslationPage> createState() => _CameraTranslationPageState();
}

class _CameraTranslationPageState extends ConsumerState<CameraTranslationPage> {
  bool _busy = false;

  Future<void> _captureAndTranslate() async {
    setState(() => _busy = true);
    final ocrRepo = ref.read(ocrRepositoryProvider);
    final transRepo = ref.read(translationRepositoryProvider);
    final target = ref.read(translationProvider).targetLang;

    final ocrResult = await ocrRepo.recognizeTextFromCamera();
    await ocrResult.fold((f) async {
      ref.read(ocrProvider.notifier).setError(f.message);
    }, (r) async {
      ref.read(ocrProvider.notifier).setResult(r);
      ref.read(translationProvider.notifier).setLoading();
      final t = await transRepo.translate(r.text, from: r.detectedLanguage ?? 'auto', to: target);
      t.fold((f) => ref.read(translationProvider.notifier).setError(f.message),
        (tr) => ref.read(translationProvider.notifier).setResult(tr));
    });
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final ts = ref.watch(translationProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Translate')),
      body: Center(
        child: _busy
          ? const LoadingDisplay(message: 'Capturing & translating...')
          : Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.camera_alt, size: 80, color: AppColors.translationColor.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text('Point camera at text to translate', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _captureAndTranslate,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture & Translate'),
              ),
              if (ts.status == TranslationStatus.success && ts.result != null) ...[
                const SizedBox(height: 24),
                TranslationResultCard(result: ts.result!),
              ],
            ]),
      ),
    );
  }
}
