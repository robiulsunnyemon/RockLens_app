import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../values/app_dimensions.dart';

enum OtzarDialogType { info, success, error, warning }

class OtzarDialog {
  OtzarDialog._();

  static Future<T?> show<T>({
    required String title,
    required String message,
    String confirmText = 'OK',
    VoidCallback? onConfirm,
    String? cancelText,
    VoidCallback? onCancel,
    OtzarDialogType type = OtzarDialogType.info,
    bool barrierDismissible = false,
  }) {
    Color accentColor;
    IconData icon;

    switch (type) {
      case OtzarDialogType.success:
        accentColor = AppColors.emerald;
        icon = Icons.check_circle_outline_rounded;
        break;
      case OtzarDialogType.error:
        accentColor = AppColors.rust;
        icon = Icons.error_outline_rounded;
        break;
      case OtzarDialogType.warning:
        accentColor = const Color(0xFFFF9100);
        icon = Icons.warning_amber_rounded;
        break;
      case OtzarDialogType.info:
        accentColor = AppColors.ore;
        icon = Icons.info_outline_rounded;
        break;
    }

    return Get.dialog<T>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.p24),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.p24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppDimensions.radius24,
            border: Border.all(
              color: accentColor.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 30,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: accentColor.withValues(alpha: 0.12),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header Box
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.12),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppDimensions.p16),

              // Title
              Text(
                title,
                style: AppTypography.displayMedium.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.p10),

              // Message Body
              Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.p24),

              // Action Buttons
              Row(
                children: [
                  if (cancelText != null) ...[
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Get.back();
                          onCancel?.call();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.p12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.r12),
                          ),
                        ),
                        child: Text(
                          cancelText,
                          style: AppTypography.hudTicker.copyWith(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.p12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        onConfirm?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: AppColors.litho,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.p12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.r12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        confirmText,
                        style: AppTypography.buttonText.copyWith(
                          color: AppColors.litho,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
    );
  }
}
