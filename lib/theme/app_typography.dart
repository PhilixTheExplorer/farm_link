import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// FarmLink typography using Mali and Sarabun fonts
class AppTypography {
  // Display Typography - Mali font
  static TextTheme maliTextTheme = TextTheme(
    displayLarge: GoogleFonts.mali(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
    ),
    displayMedium: GoogleFonts.mali(
      fontSize: 45,
      fontWeight: FontWeight.w400,
    ),
    displaySmall: GoogleFonts.mali(
      fontSize: 36,
      fontWeight: FontWeight.w400,
    ),
    headlineLarge: GoogleFonts.mali(
      fontSize: 32,
      fontWeight: FontWeight.w400,
    ),
    headlineMedium: GoogleFonts.mali(
      fontSize: 28,
      fontWeight: FontWeight.w400,
    ),
    headlineSmall: GoogleFonts.mali(
      fontSize: 24,
      fontWeight: FontWeight.w400,
    ),
    titleLarge: GoogleFonts.mali(
      fontSize: 22,
      fontWeight: FontWeight.w500,
    ),
  );

  // Body Typography - Sarabun font
  static TextTheme sarabunTextTheme = TextTheme(
    titleLarge: GoogleFonts.sarabun(
      fontSize: 22,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: GoogleFonts.sarabun(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    titleSmall: GoogleFonts.sarabun(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    bodyLarge: GoogleFonts.sarabun(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
    ),
    bodyMedium: GoogleFonts.sarabun(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodySmall: GoogleFonts.sarabun(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),
    labelLarge: GoogleFonts.sarabun(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: GoogleFonts.sarabun(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.sarabun(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );

  // Combined TextTheme
  static TextTheme get textTheme {
    return maliTextTheme.copyWith(
      titleMedium: sarabunTextTheme.titleMedium,
      titleSmall: sarabunTextTheme.titleSmall,
      bodyLarge: sarabunTextTheme.bodyLarge,
      bodyMedium: sarabunTextTheme.bodyMedium,
      bodySmall: sarabunTextTheme.bodySmall,
      labelLarge: sarabunTextTheme.labelLarge,
      labelMedium: sarabunTextTheme.labelMedium,
      labelSmall: sarabunTextTheme.labelSmall,
    );
  }
}
