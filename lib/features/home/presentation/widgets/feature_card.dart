import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/widgets/glass_card.dart';

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;
  final int animationDelay;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.onTap,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = _resolvedIconColor(context, color);
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return Semantics(
      label: title,
      hint: subtitle ?? 'Tap to open $title',
      button: true,
      child: GlassCard(
        onTap: () {
          HapticUtils.mediumImpact();
          onTap();
        },
        borderRadius: 20,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: AppTypography.labelSmall.copyWith(
                    color: subtitleColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(
          duration: const Duration(milliseconds: 400),
          delay: Duration(milliseconds: animationDelay),
        ).slideY(
          begin: 0.2,
          end: 0,
          duration: const Duration(milliseconds: 400),
          delay: Duration(milliseconds: animationDelay),
        );
  }

  Color _resolvedIconColor(BuildContext context, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final face = isDark ? AppColors.darkSurface : AppColors.surface;
    final target = isDark ? Colors.white : Colors.black;
    var candidate = color;
    if (_contrast(candidate, face) >= 3.5) return candidate;
    for (var factor = 0.05; factor <= 0.95; factor += 0.05) {
      candidate = Color.lerp(color, target, factor)!;
      if (_contrast(candidate, face) >= 3.5) return candidate;
    }
    return target.withValues(alpha: 0.9);
  }

  double _contrast(Color a, Color b) {
    final l1 = a.computeLuminance();
    final l2 = b.computeLuminance();
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }
}
