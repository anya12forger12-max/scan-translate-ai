import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding, margin;
  final double borderRadius;
  final double? width, height;
  final VoidCallback? onTap;

  const GlassCard({
    super.key, required this.child, this.padding, this.margin,
    this.borderRadius = 20, this.width, this.height, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.3);
    return Container(
      width: width, height: height, margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.3)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(borderRadius), child: child),
            ),
          ),
        ),
      ),
    );
  }
}
