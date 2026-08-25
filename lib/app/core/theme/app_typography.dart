import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized Typography system using local Poppins & Inter fonts.
abstract class AppTypography {
  AppTypography._();

  static const String poppins = 'Poppins';
  static const String inter = 'Inter';

  // Display & Headline styles (Poppins font)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: poppins,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.ore,
    letterSpacing: 3.0,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: poppins,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.quartz,
    letterSpacing: 0.5,
    height: 1.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: poppins,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.quartz,
    letterSpacing: 0.3,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: poppins,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.quartz,
    letterSpacing: 0.2,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: poppins,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.quartz,
    letterSpacing: 0.2,
  );

  // Body & Content styles (Inter font)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: inter,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.quartz,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: inter,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: inter,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
    height: 1.4,
  );

  // Tech / HUD / Mono styles
  static const TextStyle hudTicker = TextStyle(
    fontFamily: inter,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.cyan,
    letterSpacing: 1.0,
  );

  static const TextStyle monoTag = TextStyle(
    fontFamily: inter,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.ore,
    letterSpacing: 1.5,
  );

  static const TextStyle monoSubtitle = TextStyle(
    fontFamily: inter,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.muted,
    letterSpacing: 2.5,
  );

  static const TextStyle monoFooter = TextStyle(
    fontFamily: inter,
    fontSize: 9,
    fontWeight: FontWeight.w500,
    color: AppColors.subtle,
    letterSpacing: 1.2,
  );

  // Keypad & Button Text
  static const TextStyle buttonText = TextStyle(
    fontFamily: poppins,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.litho,
    letterSpacing: 0.3,
  );

  static const TextStyle keypadDigit = TextStyle(
    fontFamily: poppins,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: AppColors.quartz,
  );
}
