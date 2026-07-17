import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/loading_display.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../app/di/providers.dart';
import '../providers/translation_provider.dart';
import '../widgets/language_selector.dart';
import '../widgets/translation_card.dart';
import '../../../ocr/presentation/providers/ocr_provider.dart';

class CameraTranslationPage extends ConsumerWidget {
  const CameraTranslationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transState = ref.watch(translationProvider);
    final ocrState = ref.watch(ocrProvider);
    final transNotifier = ref.read(translationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Translation'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: LanguageSelector(
                      selectedCode: transState.targetLanguage,
                      onChanged: (lang) => transNotifier.setTargetLanguage(lang),
                      label: 'Target language',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'Image source selection',
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkSurface
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.translate_rounded,
                      size: 64,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Take a photo or select from gallery\nto translate text in the image',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            HapticUtils.mediumImpact();
                            ref.read(ocrProvider.notifier).setLoading();
                            transNotifier.setLoading();

                            final ocrRepo = ref.read(ocrRepositoryProvider);
                            final ocrResult = await ocrRepo.recognizeTextFromCamera();
                            ocrResult.fold(
                              (failure) {
                                ref.read(ocrProvider.notifier).setError(failure.message);
                              },
                              (result) {
                                ref.read(ocrProvider.notifier).setResult(result);
                                transNotifier.setLoading();
                                final transRepo = ref.read(translationRepositoryProvider);
                                transRepo
                                    .translateText(
                                      text: result.text,
                                      targetLanguage: transState.targetLanguage,
                                    )
                                    .then((transResult) {
                                  transResult.fold(
                                    (f) => transNotifier.setError(f.message),
                                    (r) => transNotifier.setResult(r),
                                  );
                                });
                              },
                            );
                          },
                          icon: const Icon(Icons.camera_alt_rounded),
                          label: const Text('Camera'),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: () async {
                            HapticUtils.mediumImpact();
                            ref.read(ocrProvider.notifier).setLoading();
                            transNotifier.setLoading();

                            final ocrRepo = ref.read(ocrRepositoryProvider);
                            final ocrResult = await ocrRepo.recognizeTextFromGallery();
                            ocrResult.fold(
                              (failure) {
                                ref.read(ocrProvider.notifier).setError(failure.message);
                              },
                              (result) {
                                ref.read(ocrProvider.notifier).setResult(result);
                                final transRepo = ref.read(translationRepositoryProvider);
                                transRepo
                                    .translateText(
                                      text: result.text,
                                      targetLanguage: transState.targetLanguage,
                                    )
                                    .then((transResult) {
                                  transResult.fold(
                                    (f) => transNotifier.setError(f.message),
                                    (r) => transNotifier.setResult(r),
                                  );
                                });
                              },
                            );
                          },
                          icon: const Icon(Icons.photo_library_rounded),
                          label: const Text('Gallery'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (transState.status == TranslationStatus.loading)
              const LoadingDisplay(message: 'Processing translation...'),
            if (transState.status == TranslationStatus.error)
              ErrorDisplay(
                message: transState.errorMessage ?? 'Translation failed.',
                actionLabel: 'Try Again',
                onAction: () => transNotifier.reset(),
              ),
            if (transState.status == TranslationStatus.success &&
                transState.result != null)
              TranslationCard(
                result: transState.result!,
                onTextToSpeech: () {
                  final repo = ref.read(translationRepositoryProvider);
                  repo.textToSpeech(
                    text: transState.result!.translatedText,
                    language: transState.targetLanguage,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
