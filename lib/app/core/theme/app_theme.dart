import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import '../values/app_dimensions.dart';

/// Centralized ThemeData configuration.
abstract class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTypography.inter,
      scaffoldBackgroundColor: AppColors.litho,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.ore,
        onPrimary: AppColors.litho,
        secondary: AppColors.cyan,
        onSecondary: AppColors.litho,
        surface: AppColors.surface,
        onSurface: AppColors.quartz,
        error: AppColors.rust,
        onError: AppColors.quartz,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.ore),
        titleTextStyle: AppTypography.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ore,
          foregroundColor: AppColors.litho,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.radius16,
          ),
          textStyle: AppTypography.buttonText,
          elevation: 4,
          shadowColor: AppColors.goldGlow,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.radius16,
          side: const BorderSide(color: AppColors.goldBorder, width: 1),
        ),
      ),
    );
  }
}
