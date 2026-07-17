import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ScannerOverlay extends StatelessWidget {
  final String? label;
  final Color borderColor;

  const ScannerOverlay({
    super.key,
    this.label,
    this.borderColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScannerOverlayPainter(borderColor: borderColor),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (label != null)
              Semantics(
                label: label,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;

  _ScannerOverlayPainter({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final scanWindow = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.75,
      height: size.width * 0.75,
    );

    canvas.save();

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(RRect.fromRectAndRadius(scanWindow, const Radius.circular(16))),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.5),
    );

    canvas.restore();

    final cornerPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const cornerLength = 30.0;

    final corners = [
      Offset(scanWindow.left, scanWindow.top),
      Offset(scanWindow.right, scanWindow.top),
      Offset(scanWindow.left, scanWindow.bottom),
      Offset(scanWindow.right, scanWindow.bottom),
    ];

    for (final corner in corners) {
      final isLeft = corner.dx == scanWindow.left;
      final isRight = corner.dx == scanWindow.right;
      final isTop = corner.dy == scanWindow.top;
      final isBottom = corner.dy == scanWindow.bottom;

      if (isTop) {
        canvas.drawLine(
          corner,
          corner + Offset(isLeft ? cornerLength : -cornerLength, 0),
          cornerPaint,
        );
        canvas.drawLine(
          corner,
          corner + Offset(0, cornerLength),
          cornerPaint,
        );
      }
      if (isBottom) {
        canvas.drawLine(
          corner,
          corner + Offset(isLeft ? cornerLength : -cornerLength, 0),
          cornerPaint,
        );
        canvas.drawLine(
          corner,
          corner + Offset(0, -cornerLength),
          cornerPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor;
  }
}
