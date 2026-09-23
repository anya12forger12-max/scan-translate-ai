import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Controlled camera-error view used as the [MobileScanner] `errorBuilder`.
///
/// The plugin's default error widget is a plain black box with an error icon,
/// which leaves the user with no explanation and no recovery path. This view
/// shows a readable message for the failure (permission revoked while
/// scanning, camera occupied by another application, unsupported device) and
/// a retry action so the failure state is always recoverable.
class ScannerErrorView extends StatelessWidget {
  final MobileScannerException error;
  final VoidCallback onRetry;

  const ScannerErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final message = error.errorDetails?.message ?? error.errorCode.message;
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.videocam_off_rounded,
                size: 48,
                color: AppColors.textSecondaryOf(context),
              ),
              const SizedBox(height: 12),
              Text(
                'Scanner unavailable',
                style: AppTypography.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondaryOf(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}