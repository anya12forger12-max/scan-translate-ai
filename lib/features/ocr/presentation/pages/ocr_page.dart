import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/utils/permission_utils.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/widgets/loading_display.dart';
import '../../../../app/di/providers.dart';
import '../providers/ocr_provider.dart';
import '../widgets/camera_preview.dart';
import '../widgets/ocr_text_display.dart';

class OcrPage extends ConsumerWidget {
  const OcrPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ocrState = ref.watch(ocrProvider);
    final ocrNotifier = ref.read(ocrProvider.notifier);
    final ocrRepo = ref.read(ocrRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Text Recognition'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Semantics(
              label: 'Image source selection area',
              child: CameraPreviewPlaceholder(
                onCameraCapture: () async {
                  HapticUtils.mediumImpact();
                  ocrNotifier.setLoading();
                  final result = await ocrRepo.recognizeTextFromCamera();
                  result.fold(
                    (failure) => ocrNotifier.setError(failure.message),
                    (result) => ocrNotifier.setResult(result),
                  );
                },
                onGalleryPick: () async {
                  HapticUtils.mediumImpact();
                  ocrNotifier.setLoading();
                  final result = await ocrRepo.recognizeTextFromGallery();
                  result.fold(
                    (failure) => ocrNotifier.setError(failure.message),
                    (result) => ocrNotifier.setResult(result),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            if (ocrState.status == OcrStatus.loading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: LoadingDisplay(message: 'Recognizing text...'),
              ),
            if (ocrState.status == OcrStatus.error)
              ErrorDisplay(
                message: ocrState.errorMessage ?? 'Text recognition failed.',
                actionLabel: 'Try Again',
                onAction: () => ocrNotifier.reset(),
              ),
            if (ocrState.status == OcrStatus.success && ocrState.result != null)
              OcrTextDisplay(
                text: ocrState.result!.text,
                detectedLanguage: ocrState.result!.detectedLanguage,
                onTranslate: () {
                  Navigator.pushNamed(
                    context,
                    '/translate',
                    arguments: {'text': ocrState.result!.text},
                  );
                },
                onShare: () {
                  SharePlus.instance.share(
                    ShareParams(text: ocrState.result!.text),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
