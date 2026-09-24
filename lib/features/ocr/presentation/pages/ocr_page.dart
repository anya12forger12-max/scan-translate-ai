import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/widgets/loading_display.dart';
import '../providers/ocr_provider.dart';
import '../widgets/ocr_text_display.dart';

class OcrPage extends ConsumerWidget {
  const OcrPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final os = ref.watch(ocrProvider);
    final n = ref.read(ocrProvider.notifier);
    final repo = ref.read(ocrRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('OCR Text Recognition')),
      body: SingleChildScrollView(
        child: Column(children: [
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Column(children: [
              Icon(Icons.text_snippet_rounded, size: 64, color: AppColors.primary.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text('Select an image to recognize text',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton.icon(onPressed: () async {
                  HapticUtils.mediumImpact(); n.setLoading();
                  (await repo.recognizeTextFromCamera()).fold((f) => n.setError(f.message), (r) => n.setResult(r));
                }, icon: const Icon(Icons.camera_alt), label: const Text('Camera')),
                const SizedBox(width: 16),
                OutlinedButton.icon(onPressed: () async {
                  HapticUtils.mediumImpact(); n.setLoading();
                  (await repo.recognizeTextFromGallery()).fold((f) => n.setError(f.message), (r) => n.setResult(r));
                }, icon: const Icon(Icons.photo_library), label: const Text('Gallery')),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          if (os.status == OcrStatus.loading) const Padding(padding: EdgeInsets.all(32), child: LoadingDisplay(message: 'Recognizing text...')),
          if (os.status == OcrStatus.error) ErrorDisplay(message: os.errorMessage ?? 'Failed.', actionLabel: 'Retry', onAction: () => n.reset()),
          if (os.status == OcrStatus.success && os.result != null) OcrTextDisplay(
            text: os.result!.text, detectedLanguage: os.result!.detectedLanguage,
            onTranslate: () => Navigator.pushNamed(context, '/translate', arguments: {'text': os.result!.text}),
            onShare: () => Share.share(os.result!.text),
          ),
        ]),
      ),
    );
  }
}
