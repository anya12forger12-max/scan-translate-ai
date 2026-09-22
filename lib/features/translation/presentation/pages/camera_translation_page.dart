import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/widgets/loading_display.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../app/di/providers.dart';
import '../providers/translation_provider.dart';
import '../widgets/language_selector.dart';
import '../widgets/translation_card.dart';
import '../../../ocr/domain/entities/ocr_result.dart';
import '../../../ocr/presentation/providers/ocr_provider.dart';

class CameraTranslationPage extends ConsumerStatefulWidget {
  const CameraTranslationPage({super.key});

  @override
  ConsumerState<CameraTranslationPage> createState() =>
      _CameraTranslationPageState();
}

class _CameraTranslationPageState extends ConsumerState<CameraTranslationPage> {
  @override
  void dispose() {
    ref.read(translationProvider.notifier).clearError();
    ref.read(ocrProvider.notifier).clearError();
    super.dispose();
  }

  Future<void> _translateFromImage(
    Future<Either<Failure, OcrResult>> Function() capture,
  ) async {
    final transNotifier = ref.read(translationProvider.notifier);
    final targetLanguage = ref.read(translationProvider).targetLanguage;

    HapticUtils.mediumImpact();
    transNotifier.setLoading();

    final ocrResult = await capture();
    // The page may be gone by the time the picker/OCR completes. Writing the
    // outcome into the shared providers afterwards would leak a stale result
    // or error into the next screen that happens to open.
    if (!mounted) return;

    ocrResult.fold(
      (failure) {
        transNotifier.setError(failure.message);
      },
      (result) async {
        final transRepo = ref.read(translationRepositoryProvider);
        final outcome = await transRepo.translateText(
          text: result.text,
          targetLanguage: targetLanguage,
        );
        if (!mounted) return;
        outcome.fold(
          (f) => transNotifier.setError(f.message),
          (r) => transNotifier.setResult(r),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final transState = ref.watch(translationProvider);
    final transNotifier = ref.read(translationProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Camera Translation')),
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
                      onChanged: (lang) =>
                          transNotifier.setTargetLanguage(lang),
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
                          onPressed:
                              transState.status == TranslationStatus.loading
                                  ? null
                                  : () => _translateFromImage(
                                        () => ref
                                            .read(ocrRepositoryProvider)
                                            .recognizeTextFromCamera(),
                                      ),
                          icon: const Icon(Icons.camera_alt_rounded),
                          label: const Text('Camera'),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed:
                              transState.status == TranslationStatus.loading
                                  ? null
                                  : () => _translateFromImage(
                                        () => ref
                                            .read(ocrRepositoryProvider)
                                            .recognizeTextFromGallery(),
                                      ),
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
