import 'package:flutter/material.dart';

/// Centralized color palette for the Otzar application.
/// Derived from the official design tokens and Figma brand guidelines.
abstract class AppColors {
  AppColors._();

  // Primary Ore / Gold Shades
  static const Color ore = Color(0xFFD4AF37);
  static const Color oreDim = Color(0xFFC58B2B);
  static const Color oreDark = Color(0xFFB8860B);
  static const Color oreLight = Color(0xFFFFDF73);
  static const Color goldGlow = Color(0x80D4AF37);
  static const Color goldBorder = Color(0x33D4AF37); // rgba(212,175,55,0.2)
  static const Color goldSubtle = Color(0x1AD4AF37); // rgba(212,175,55,0.1)

  // Surface & Dark Backgrounds (Litho Palette)
  static const Color background = Color(0xFF0A0D12);
  static const Color litho = Color(0xFF0F1217);
  static const Color surface = Color(0xFF181C24);
  static const Color surface2 = Color(0xFF1E2330);
  static const Color surface3 = Color(0xFF252B3A);
  static const Color surfaceBorder = Color(0xFF1E2330);

  // Status & Telemetry Accent Colors
  static const Color emerald = Color(0xFF00C853);
  static const Color emeraldDim = Color(0xFF1B5E20);
  static const Color emeraldSubtle = Color(0x1A00C853);
  static const Color cyan = Color(0xFF00E5FF);
  static const Color cyanSubtle = Color(0x1A00E5FF);
  static const Color rust = Color(0xFFE65100);
  static const Color ember = Color(0xFFE65100);
  static const Color amber = Color(0xFFFF9100);

  // Typography & Content Colors
  static const Color quartz = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color muted = Color(0xFF8B929E);
  static const Color subtle = Color(0xFF4B5563);
  static const Color transparent = Colors.transparent;

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [oreDim, ore],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [surface, litho],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const RadialGradient splashRadialGradient = RadialGradient(
    center: Alignment.center,
    radius: 0.85,
    colors: [surface, litho],
    stops: [0.0, 0.7],
  );
}
