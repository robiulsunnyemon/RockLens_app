import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/values/app_dimensions.dart';

class HudBarWidget extends StatelessWidget {
  final int pending;

  const HudBarWidget({
    super.key,
    this.pending = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.p12,
        vertical: AppDimensions.p8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r8),
        border: Border.all(
          color: AppColors.cyan.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // GPS Accuracy
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.emerald,
                ),
              ),
              const SizedBox(width: AppDimensions.p6),
              Text(
                'SAT ×12 ±2.8m',
                style: AppTypography.hudTicker.copyWith(
                  color: AppColors.emerald,
                  fontSize: 9.5,
                ),
              ),
            ],
          ),

          // Staged Queue Count
          Text(
            '$pending STAGED',
            style: AppTypography.hudTicker.copyWith(
              color: AppColors.ore,
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Vault Offline Indicator
          Row(
            children: [
              Text(
                'OFFLINE',
                style: AppTypography.hudTicker.copyWith(
                  color: AppColors.subtle,
                  fontSize: 9.5,
                ),
              ),
              const SizedBox(width: AppDimensions.p6),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.ember,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
