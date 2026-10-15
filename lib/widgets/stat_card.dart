import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String? tag;
  final String value;
  final Color valueColor;
  final String detail;
  final VoidCallback? onTap;
  final bool isLayer;

  const StatCard({
    super.key,
    required this.label,
    this.tag,
    required this.value,
    required this.valueColor,
    required this.detail,
    this.onTap,
    this.isLayer = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isLayer
        ? const Color(0xBF04150A)
        : const Color(0xBF081324);
    final borderColor = isLayer
        ? const Color(0x3D00FF66)
        : const Color(0x3D00A8FF);
    final textSecondary = isLayer
        ? const Color(0xFF86E7A4)
        : const Color(0xFF94A3B8);
    final textMuted = isLayer
        ? const Color(0xFF3B7A4E)
        : const Color(0xFF475569);

    final cardContent = Container(
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: valueColor.withValues(alpha: 0.08),
            blurRadius: 12,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top accent indicator bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    valueColor.withValues(alpha: 0.9),
                    valueColor.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (tag != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: valueColor.withValues(alpha: 0.12),
                          border: Border.all(color: valueColor.withValues(alpha: 0.35)),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          tag!,
                          style: GoogleFonts.jetBrainsMono(
                            color: valueColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      label.toUpperCase(),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10.5,
                        color: textSecondary,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 22,
                    color: valueColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    shadows: [
                      Shadow(
                        color: valueColor.withValues(alpha: 0.45),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  detail,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10.5,
                    color: textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Subtle click indicator icon on top right (only shown if onTap is provided)
          if (onTap != null)
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.edit_note,
                color: textMuted.withValues(alpha: 0.6),
                size: 14,
              ),
            ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: cardContent,
      );
    }

    return cardContent;
  }
}
