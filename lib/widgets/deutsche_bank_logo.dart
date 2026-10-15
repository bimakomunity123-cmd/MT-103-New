import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Painter that draws the official Deutsche Bank square + diagonal slash logo emblem.
class DeutscheBankEmblemPainter extends CustomPainter {
  final Color color;
  final Color? fillColor;

  const DeutscheBankEmblemPainter({
    required this.color,
    this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.shortestSide;
    // Square frame stroke thickness ~ 12% of size
    final double strokeWidth = s * 0.12;

    if (fillColor != null) {
      final Paint bgPaint = Paint()
        ..color = fillColor!
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, s, s), bgPaint);
    }

    // Outer square frame
    final Paint framePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final double halfStroke = strokeWidth / 2;
    final Rect frameRect = Rect.fromLTWH(
      halfStroke,
      halfStroke,
      s - strokeWidth,
      s - strokeWidth,
    );
    canvas.drawRect(frameRect, framePaint);

    // Inner area bounds (inside the stroke)
    final double innerLeft = strokeWidth;
    final double innerTop = strokeWidth;
    final double innerRight = s - strokeWidth;
    final double innerBottom = s - strokeWidth;
    final double innerW = innerRight - innerLeft;

    // The iconic 53° diagonal slash
    // Bottom edge sits on innerBottom, top edge touches innerTop
    final double slashW = innerW * 0.28;
    final double bottomStart = innerLeft + innerW * 0.12;
    final double topStart = innerRight - innerW * 0.12 - slashW;

    final Path slashPath = Path()
      ..moveTo(bottomStart, innerBottom)
      ..lineTo(bottomStart + slashW, innerBottom)
      ..lineTo(topStart + slashW, innerTop)
      ..lineTo(topStart, innerTop)
      ..close();

    final Paint slashPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(slashPath, slashPaint);
  }

  @override
  bool shouldRepaint(covariant DeutscheBankEmblemPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.fillColor != fillColor;
  }
}

/// Widget for the Deutsche Bank iconic emblem
class DeutscheBankEmblem extends StatelessWidget {
  final double size;
  final Color color;
  final Color? backgroundColor;
  final bool hasGlow;

  const DeutscheBankEmblem({
    super.key,
    this.size = 38,
    this.color = const Color(0xFF0088FF),
    this.backgroundColor,
    this.hasGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF03070E),
        borderRadius: BorderRadius.circular(2),
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: DeutscheBankEmblemPainter(
          color: color,
        ),
      ),
    );
  }
}

/// Combined Deutsche Bank Brand Header (Text on Left, Emblem on Right as in Image 2, or styled for current cyber theme)
class DeutscheBankBrandLogo extends StatelessWidget {
  final double fontSize;
  final double iconSize;
  final Color textColor;
  final Color iconColor;
  final bool iconOnRight; // Image 2 has text on left, icon on right
  final bool hasGlow;

  const DeutscheBankBrandLogo({
    super.key,
    this.fontSize = 28,
    this.iconSize = 44,
    this.textColor = Colors.white,
    this.iconColor = const Color(0xFF0088FF),
    this.iconOnRight = true, // Matches Image 2
    this.hasGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      'Deutsche Bank',
      style: GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: textColor,
        letterSpacing: -0.5,
        shadows: hasGlow
            ? [
                Shadow(
                  color: iconColor.withValues(alpha: 0.5),
                  blurRadius: 18,
                ),
              ]
            : null,
      ),
    );

    final emblemWidget = DeutscheBankEmblem(
      size: iconSize,
      color: iconColor,
      hasGlow: hasGlow,
    );

    if (iconOnRight) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: textWidget,
          ),
          SizedBox(width: fontSize * 0.45),
          emblemWidget,
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          emblemWidget,
          SizedBox(width: fontSize * 0.45),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: textWidget,
          ),
        ],
      );
    }
  }
}
