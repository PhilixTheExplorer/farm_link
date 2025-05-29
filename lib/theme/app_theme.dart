import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// FarmLink theme configuration
class AppTheme {
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.tamarindBrown,
        onPrimary: Colors.white,
        secondary: AppColors.ricePaddyGreen,
        onSecondary: Colors.white,
        tertiary: AppColors.chilliRed,
        onTertiary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        background: AppColors.jasmineBeige,
        onBackground: AppColors.charcoalBlack,
        surface: AppColors.bambooCream,
        onSurface: AppColors.charcoalBlack,
        surfaceVariant: AppColors.bambooCream.withOpacity(0.7),
        onSurfaceVariant: AppColors.palmAshGray,
        outline: AppColors.palmAshGray.withOpacity(0.5),
      ),

      // Typography
      textTheme: AppTypography.textTheme,

      // Component Themes
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bambooCream,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.sarabunTextTheme.titleLarge?.copyWith(
          color: Colors.black, // Ensure title text style is also black
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: AppColors.bambooCream,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        margin: const EdgeInsets.all(8.0),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.tamarindBrown,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          textStyle: AppTypography.sarabunTextTheme.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.tamarindBrown,
          side: const BorderSide(color: AppColors.tamarindBrown, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          textStyle: AppTypography.sarabunTextTheme.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.tamarindBrown,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          textStyle: AppTypography.sarabunTextTheme.labelLarge,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bambooCream,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: AppColors.palmAshGray.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(
            color: AppColors.ricePaddyGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTypography.sarabunTextTheme.bodyMedium?.copyWith(
          color: AppColors.palmAshGray,
        ),
        hintStyle: AppTypography.sarabunTextTheme.bodyMedium?.copyWith(
          color: AppColors.palmAshGray.withOpacity(0.7),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bambooCream,
        disabledColor: AppColors.bambooCream.withOpacity(0.5),
        selectedColor: AppColors.ricePaddyGreen,
        secondarySelectedColor: AppColors.ricePaddyGreen,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: AppTypography.sarabunTextTheme.bodySmall?.copyWith(
          color: AppColors.charcoalBlack,
        ),
        secondaryLabelStyle: AppTypography.sarabunTextTheme.bodySmall?.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: AppColors.palmAshGray.withOpacity(0.3)),
        ),
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.ricePaddyGreen,
        unselectedLabelColor: AppColors.palmAshGray,
        indicatorColor: AppColors.ricePaddyGreen,
        labelStyle: AppTypography.sarabunTextTheme.labelLarge,
        unselectedLabelStyle: AppTypography.sarabunTextTheme.labelLarge,
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.bambooCream,
        foregroundColor: AppColors.chilliRed,
        shape: const CircleBorder(),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.palmAshGray.withOpacity(0.2),
        thickness: 1,
        space: 24,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.jasmineBeige,
    );
  }
}
