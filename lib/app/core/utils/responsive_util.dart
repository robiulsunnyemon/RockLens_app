import 'package:flutter/material.dart';

/// Responsive helper utility for adaptive layouts and preventing RenderFlex overflow.
class ResponsiveUtil {
  static double width(BuildContext context) => MediaQuery.of(context).size.width;
  static double height(BuildContext context) => MediaQuery.of(context).size.height;

  static bool isSmallPhone(BuildContext context) => height(context) < 680;
  static bool isTablet(BuildContext context) => width(context) >= 600;

  /// Dynamic scale factor based on standard mobile viewport (375x812)
  static double scale(BuildContext context, double size) {
    final double factor = (width(context) / 375.0).clamp(0.85, 1.25);
    return size * factor;
  }
}

/// Extension on BuildContext for quick responsive access
extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get viewPadding => MediaQuery.of(this).padding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  bool get isSmallScreen => screenHeight < 680 || screenWidth < 360;
  bool get isTablet => screenWidth >= 600;

  double wp(double percentage) => screenWidth * (percentage / 100);
  double hp(double percentage) => screenHeight * (percentage / 100);

  double sp(double size) => ResponsiveUtil.scale(this, size);
}
