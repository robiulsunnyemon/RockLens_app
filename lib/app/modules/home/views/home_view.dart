import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/values/app_assets.dart';
import '../../../core/values/app_dimensions.dart';
import '../controllers/home_controller.dart';
import '../widgets/hero_scan_card.dart';
import '../widgets/hud_bar_widget.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.litho,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.p8),

              // 1. Top Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              AppAssets.logo,
                              width: 15,
                              height: 15,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.diamond_outlined,
                                      size: 15, color: AppColors.ore),
                            ),
                            const SizedBox(width: AppDimensions.p6),
                            Text(
                              'OTZAR APP · COMMAND CENTER',
                              style: AppTypography.hudTicker.copyWith(
                                color: AppColors.ore,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Obx(() => Text(
                              'Hello, ${controller.operatorName}',
                              style: AppTypography.displayMedium.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.p8),

                  // Avatar Circle
                  GestureDetector(
                    onTap: controller.goToProfile,
                    child: Obx(() {
                      final localPath = controller.userAvatarPath.value;
                      final remoteUrl = controller.userAvatarUrl.value;

                      Widget avatarChild;
                      if (localPath != null && File(localPath).existsSync()) {
                        avatarChild = ClipOval(
                          child: Image.file(
                            File(localPath),
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        );
                      } else if (remoteUrl != null && remoteUrl.isNotEmpty) {
                        avatarChild = ClipOval(
                          child: Image.network(
                            remoteUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Center(
                              child: Text(
                                controller.initials,
                                style: AppTypography.buttonText.copyWith(
                                  color: AppColors.litho,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        avatarChild = Center(
                          child: Text(
                            controller.initials,
                            style: AppTypography.buttonText.copyWith(
                              color: AppColors.litho,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }

                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.goldGradient,
                          border: Border.all(color: AppColors.ore, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.ore.withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: avatarChild,
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.p10),

              // 2. Dynamic HUD Bar
              Obx(() => HudBarWidget(pending: controller.pendingSyncCount.value)),
              const SizedBox(height: AppDimensions.p8),

              // 3. Dynamic Sync Alert Banner (Visible only when pending syncs exist)
              Obx(() {
                final pending = controller.pendingSyncCount.value;
                if (pending <= 0) return const SizedBox.shrink();

                return Container(
                  margin: const EdgeInsets.only(bottom: AppDimensions.p8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.p12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.ember.withValues(alpha: 0.1),
                    borderRadius: AppDimensions.radius12,
                    border: Border.all(
                      color: AppColors.ember.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.ember,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.p8),
                            Expanded(
                              child: Text(
                                '$pending ${pending == 1 ? 'Scan' : 'Scans'} Staged for Cloud Sync',
                                style: AppTypography.bodySmall.copyWith(
                                  color: const Color(0xFFFF9100),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.p8),
                      ElevatedButton(
                        onPressed: controller.goToSync,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9100),
                          foregroundColor: AppColors.litho,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.p10,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.r8),
                          ),
                        ),
                        child: Text(
                          'SYNC NOW',
                          style: AppTypography.hudTicker.copyWith(
                            color: AppColors.litho,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // 4. Hero AI Scan Card
              HeroScanCard(onTap: controller.startScanning),
              const SizedBox(height: AppDimensions.p10),

              // 5. Dynamic Real Stats Row
              Obx(() => Row(
                    children: [
                      _buildStatCard(
                        label: "Today's Finds",
                        value: '${controller.todayFindsCount.value}',
                        unit: 'specimens',
                        color: AppColors.ore,
                      ),
                      const SizedBox(width: AppDimensions.p8),
                      _buildStatCard(
                        label: 'Est. Value',
                        value: controller.estValueFormatted,
                        unit: 'approx.',
                        color: AppColors.emerald,
                      ),
                      const SizedBox(width: AppDimensions.p8),
                      _buildStatCard(
                        label: 'Pending Sync',
                        value: '${controller.pendingSyncCount.value}',
                        unit: 'in queue',
                        color: const Color(0xFFFF9100),
                      ),
                    ],
                  )),
              const SizedBox(height: AppDimensions.p12),

              // 6. Recent Specimens Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RECENT SPECIMENS',
                    style: AppTypography.hudTicker.copyWith(
                      color: AppColors.subtle,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.goToVault,
                    child: Text(
                      'VIEW ALL →',
                      style: AppTypography.hudTicker.copyWith(
                        color: AppColors.ore,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.p8),

              // 7. Recent Specimens List or High-Tech Empty State
              Expanded(
                child: Obx(() {
                  final scans = controller.recentScans;

                  if (scans.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.6),
                            borderRadius: AppDimensions.radius16,
                            border: Border.all(
                              color: AppColors.surfaceBorder,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.ore.withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: AppColors.ore.withValues(alpha: 0.25),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.radar_rounded,
                                  color: AppColors.ore,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'NO SPECIMEN DISCOVERIES RECORDED',
                                style: AppTypography.hudTicker.copyWith(
                                  color: AppColors.quartz,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Your geological vault is currently empty. Tap "INITIATE SCAN" above to classify and log your first field discovery.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.subtle,
                                  fontSize: 11.5,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: AppDimensions.p16),
                    itemCount: scans.length,
                    itemBuilder: (context, idx) {
                      final scan = scans[idx];
                      final color = Color(scan['color'] as int);

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppDimensions.p8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.p12,
                          vertical: AppDimensions.p10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppDimensions.radius16,
                          border: Border.all(
                            color: AppColors.surfaceBorder,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppDimensions.r10),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: (scan['photo'] != null && (scan['photo'] as String).isNotEmpty)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(AppDimensions.r10 - 1),
                                      child: (scan['photo'] as String).startsWith('http')
                                          ? Image.network(
                                              scan['photo'] as String,
                                              fit: BoxFit.cover,
                                              errorBuilder: (ctx, err, stack) => Center(
                                                child: Container(
                                                  width: 12,
                                                  height: 12,
                                                  decoration: BoxDecoration(
                                                    color: color,
                                                    borderRadius: BorderRadius.circular(2),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Image.file(
                                              File(scan['photo'] as String),
                                              fit: BoxFit.cover,
                                              errorBuilder: (ctx, err, stack) => Center(
                                                child: Container(
                                                  width: 12,
                                                  height: 12,
                                                  decoration: BoxDecoration(
                                                    color: color,
                                                    borderRadius: BorderRadius.circular(2),
                                                  ),
                                                ),
                                              ),
                                            ),
                                    )
                                  : Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: AppDimensions.p12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          scan['name'] as String,
                                          style: AppTypography.displayMedium.copyWith(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if ((scan['formula'] as String).isNotEmpty) ...[
                                        const SizedBox(width: AppDimensions.p6),
                                        Flexible(
                                          child: Text(
                                            scan['formula'] as String,
                                            style: AppTypography.monoTag.copyWith(
                                              color: AppColors.subtle,
                                              fontSize: 9,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        '${scan['conf']}% MATCH',
                                        style: AppTypography.hudTicker.copyWith(
                                          color: color,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          ' · ${scan['grade']}',
                                          style: AppTypography.hudTicker.copyWith(
                                            color: AppColors.subtle,
                                            fontSize: 9.5,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppDimensions.p8),
                            Text(
                              scan['time'] as String,
                              style: AppTypography.hudTicker.copyWith(
                                color: AppColors.muted,
                                fontSize: 9.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.p8,
          vertical: AppDimensions.p10,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppDimensions.radius16,
          border: Border.all(
            color: AppColors.surfaceBorder,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTypography.displayMedium.copyWith(
                color: color,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.hudTicker.copyWith(
                color: AppColors.subtle,
                fontSize: 9,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              unit,
              style: AppTypography.hudTicker.copyWith(
                color: AppColors.muted,
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
