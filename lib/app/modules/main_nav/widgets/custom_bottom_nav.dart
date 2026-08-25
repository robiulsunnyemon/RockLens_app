import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/values/app_dimensions.dart';
import '../controllers/main_nav_controller.dart';

class CustomBottomNav extends GetView<MainNavController> {
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.currentIndex.value;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.litho,
          border: const Border(
            top: BorderSide(
              color: Color(0xCC1E2330),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  current: current,
                  label: 'Home',
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                ),
                _buildNavItem(
                  index: 1,
                  current: current,
                  label: 'Discoveries',
                  icon: Icons.inventory_2_outlined,
                  activeIcon: Icons.inventory_2_rounded,
                ),
                _buildNavItem(
                  index: 2,
                  current: current,
                  label: 'GIS Map',
                  icon: Icons.map_outlined,
                  activeIcon: Icons.map_rounded,
                ),
                _buildNavItem(
                  index: 3,
                  current: current,
                  label: 'Sync',
                  icon: Icons.sync_rounded,
                  activeIcon: Icons.sync_rounded,
                  badgeCount: controller.stagedCount.value,
                ),
                _buildNavItem(
                  index: 4,
                  current: current,
                  label: 'Profile',
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNavItem({
    required int index,
    required int current,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    int? badgeCount,
  }) {
    final active = index == current;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.changePage(index),
          borderRadius: BorderRadius.circular(AppDimensions.r12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    active ? activeIcon : icon,
                    color: active ? AppColors.ore : AppColors.muted,
                    size: 22,
                  ),
                  if (badgeCount != null && badgeCount > 0)
                    Positioned(
                      top: -3,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.ember,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: AppTypography.hudTicker.copyWith(
                  color: active ? AppColors.ore : AppColors.muted,
                  fontSize: 9.5,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AppColors.ore : Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
