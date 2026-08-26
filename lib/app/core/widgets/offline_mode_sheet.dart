import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../values/app_dimensions.dart';
import '../../data/services/storage_service.dart';
import '../../routes/app_pages.dart';

class OfflineModeSheet {
  OfflineModeSheet._();

  /// Display high-tech offline field access bottom sheet
  static Future<void> show({
    VoidCallback? onRetry,
  }) {
    HapticFeedback.heavyImpact();
    final storage = Get.find<StorageService>();
    final hasLocalProfile = storage.currentUser != null;

    return Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.p20,
          AppDimensions.p16,
          AppDimensions.p20,
          AppDimensions.p24,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF14171F),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
          border: Border.all(
            color: const Color(0xFFFF9100).withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.9),
              blurRadius: 30,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.p16),

            // Pulsing Satellite / Offline Radar Header Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF9100).withValues(alpha: 0.12),
                border: Border.all(
                  color: const Color(0xFFFF9100).withValues(alpha: 0.45),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9100).withValues(alpha: 0.2),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.satellite_alt_rounded,
                color: Color(0xFFFF9100),
                size: 32,
              ),
            ),
            const SizedBox(height: AppDimensions.p16),

            // Badge Ticker
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9100).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimensions.r6),
                border: Border.all(
                  color: const Color(0xFFFF9100).withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                'NO SATELLITE / CELLULAR NETWORK DETECTED',
                style: AppTypography.hudTicker.copyWith(
                  color: const Color(0xFFFF9100),
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.9,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.p10),

            // Title
            Text(
              'Offline Field Mode Active',
              style: AppTypography.displayMedium.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.p6),

            // Description
            Text(
              'No active network connection was found. OTZAR App is fully autonomous and optimized for remote exploration without internet.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.subtle,
                fontSize: 12,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.p16),

            // Offline Capabilities HUD
            Container(
              padding: const EdgeInsets.all(AppDimensions.p12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  _buildHudRow(
                    icon: Icons.shield_outlined,
                    label: 'AES-256 Offline Vault',
                    value: 'ENCRYPTED & READY',
                    color: AppColors.emerald,
                  ),
                  const SizedBox(height: 8),
                  _buildHudRow(
                    icon: Icons.gps_fixed_rounded,
                    label: 'Live Field GPS Telemetry',
                    value: 'OPERATIONAL',
                    color: AppColors.cyan,
                  ),
                  const SizedBox(height: 8),
                  _buildHudRow(
                    icon: Icons.camera_alt_outlined,
                    label: 'Spectrometry Camera & AI',
                    value: 'AVAILABLE OFFLINE',
                    color: AppColors.ore,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.p20),

            // Actions
            if (hasLocalProfile) ...[
              // Continue in offline field mode
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    HapticFeedback.mediumImpact();
                    Get.offAllNamed(Routes.HOME);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ore,
                    foregroundColor: AppColors.litho,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r12),
                    ),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.flash_on_rounded, size: 18, color: AppColors.litho),
                      const SizedBox(width: 8),
                      Text(
                        'CONTINUE IN OFFLINE MODE',
                        style: AppTypography.buttonText.copyWith(
                          color: AppColors.litho,
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.p10),
            ],

            // Retry Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () {
                  Get.back();
                  if (onRetry != null) {
                    onRetry();
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.surfaceBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.r12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh_rounded, size: 16, color: AppColors.quartz),
                    const SizedBox(width: 6),
                    Text(
                      'Retry Connection',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.quartz,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  static Widget _buildHudRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.quartz,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: AppTypography.hudTicker.copyWith(
              color: color,
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
