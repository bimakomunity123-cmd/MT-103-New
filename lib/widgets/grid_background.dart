import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GridBackground extends StatelessWidget {
  const GridBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _GridPainter(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentBlue.withOpacity(0.08)
      ..strokeWidth = 1;

    // Draw perspective grid
    final centerX = size.width / 2;
    final horizon = size.height * 0.4;

    // Horizontal lines with perspective
    for (int i = 0; i < 20; i++) {
      final t = i / 20;
      final y = horizon + (size.height - horizon) * (t * t);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical lines converging to center
    for (int i = -10; i <= 10; i++) {
      final topX = centerX + i * 5;
      final bottomX = centerX + i * 60;
      canvas.drawLine(Offset(topX, horizon), Offset(bottomX, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
