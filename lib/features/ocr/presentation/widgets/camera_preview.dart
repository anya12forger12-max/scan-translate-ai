import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class CameraPreviewPlaceholder extends StatelessWidget {
  final VoidCallback? onCameraCapture;
  final VoidCallback? onGalleryPick;

  const CameraPreviewPlaceholder({
    super.key,
    this.onCameraCapture,
    this.onGalleryPick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.text_snippet_rounded,
            size: 64,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Select an image to recognize text',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (onCameraCapture != null)
                Semantics(
                  label: 'Capture from camera',
                  child: ElevatedButton.icon(
                    onPressed: onCameraCapture,
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Camera'),
                  ),
                ),
              if (onCameraCapture != null && onGalleryPick != null)
                const SizedBox(width: 16),
              if (onGalleryPick != null)
                Semantics(
                  label: 'Pick from gallery',
                  child: OutlinedButton.icon(
                    onPressed: onGalleryPick,
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Gallery'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
