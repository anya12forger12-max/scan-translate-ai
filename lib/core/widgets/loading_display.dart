import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class LoadingDisplay extends StatelessWidget {
  final String? message;
  final double size;
  const LoadingDisplay({super.key, this.message, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: size, height: size, child: const CircularProgressIndicator()),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
