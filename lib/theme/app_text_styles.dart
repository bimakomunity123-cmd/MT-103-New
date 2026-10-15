import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get monoBase => GoogleFonts.jetBrainsMono(
    color: AppColors.textPrimary,
  );

  static TextStyle title = GoogleFonts.jetBrainsMono(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 3,
  );

  static TextStyle pageTitle = GoogleFonts.jetBrainsMono(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle subtitle = GoogleFonts.jetBrainsMono(
    fontSize: 11,
    color: AppColors.textMuted,
  );

  static TextStyle label = GoogleFonts.jetBrainsMono(
    fontSize: 11,
    color: AppColors.textSecondary,
    letterSpacing: 1.5,
  );

  static TextStyle body = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMuted = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static TextStyle balance = GoogleFonts.jetBrainsMono(
    fontSize: 42,
    fontWeight: FontWeight.w700,
    color: AppColors.accentGreen,
    letterSpacing: 2,
    shadows: [
      Shadow(
        color: AppColors.accentGreen.withOpacity(0.5),
        blurRadius: 20,
      ),
    ],
  );

  static TextStyle button = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    color: AppColors.textPrimary,
    letterSpacing: 2,
  );
}
