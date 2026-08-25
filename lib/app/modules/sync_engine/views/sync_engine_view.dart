import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/values/app_dimensions.dart';
import '../controllers/sync_engine_controller.dart';

class SyncEngineView extends GetView<SyncEngineController> {
  const SyncEngineView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.litho,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(
            left: AppDimensions.p16,
            right: AppDimensions.p16,
            top: AppDimensions.p12,
            bottom: AppDimensions.p32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sync Engine',
                    style: AppTypography.displayMedium.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.p8,
                      vertical: AppDimensions.p4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.ember.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.r8),
                      border: Border.all(
                        color: AppColors.ember.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      'OFFLINE',
                      style: AppTypography.hudTicker.copyWith(
                        color: AppColors.ember,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.p16),

              // Status Summary (3 Cards)
              Obx(() => Row(
                    children: [
                      _buildSummaryCard(
                        label: 'PENDING',
                        value: '${controller.pendingCount}',
                        color: const Color(0xFFFF9100),
                      ),
                      const SizedBox(width: AppDimensions.p8),
                      _buildSummaryCard(
                        label: 'QUEUED SIZE',
                        value: '9.3 MB',
                        color: AppColors.ore,
                      ),
                      const SizedBox(width: AppDimensions.p8),
                      _buildSummaryCard(
                        label: 'SYNCED TODAY',
                        value: '${controller.syncedTodayCount.value}',
                        color: AppColors.emerald,
                      ),
                    ],
                  )),
              const SizedBox(height: AppDimensions.p16),

              // Controls Card
              Container(
                padding: const EdgeInsets.all(AppDimensions.p16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppDimensions.radius20,
                  border: Border.all(
                    color: AppColors.surfaceBorder,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cellular Data Sync',
                              style: AppTypography.displayMedium.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Use mobile data when WiFi unavailable',
                              style: AppTypography.hudTicker.copyWith(
                                color: AppColors.subtle,
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                        Obx(() => Switch(
                              value: controller.isCellularEnabled.value,
                              onChanged: (_) => controller.toggleCellular(),
                              activeThumbColor: AppColors.ore,
                              activeTrackColor: AppColors.ore.withValues(alpha: 0.3),
                              inactiveThumbColor: AppColors.muted,
                              inactiveTrackColor: AppColors.surfaceBorder,
                            )),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.p12),

                    // Force Sync Button
                    Obx(() {
                      final syncing = controller.isSyncing.value;
                      return SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: syncing ? null : controller.forceBackgroundSync,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: syncing
                                ? AppColors.surface
                                : AppColors.ore,
                            foregroundColor: syncing
                                ? AppColors.ore
                                : AppColors.litho,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.r12),
                              side: BorderSide(
                                color: syncing
                                    ? AppColors.ore.withValues(alpha: 0.4)
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                          child: syncing
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                AppColors.ore),
                                      ),
                                    ),
                                    const SizedBox(width: AppDimensions.p8),
                                    Text(
                                      'Background Sync Active...',
                                      style: AppTypography.buttonText.copyWith(
                                        color: AppColors.ore,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Force Background Sync',
                                  style: AppTypography.buttonText.copyWith(
                                    color: AppColors.litho,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.p16),

              // Legend
              Row(
                children: [
                  _buildLegendDot(color: AppColors.emerald, label: 'SYNCED'),
                  const SizedBox(width: AppDimensions.p12),
                  _buildLegendDot(color: AppColors.cyan, label: 'AI PROCESSING'),
                  const SizedBox(width: AppDimensions.p12),
                  _buildLegendDot(
                      color: const Color(0xFFFF9100),
                      label: 'AWAITING CONN.'),
                ],
              ),
              const SizedBox(height: AppDimensions.p12),

              // Sync Table Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(
                      'ID',
                      style: AppTypography.hudTicker.copyWith(
                        color: AppColors.muted,
                        fontSize: 8.5,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'MINERAL',
                      style: AppTypography.hudTicker.copyWith(
                        color: AppColors.muted,
                        fontSize: 8.5,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 55,
                    child: Text(
                      'SIZE',
                      style: AppTypography.hudTicker.copyWith(
                        color: AppColors.muted,
                        fontSize: 8.5,
                      ),
                    ),
                  ),
                  Text(
                    'STATUS',
                    style: AppTypography.hudTicker.copyWith(
                      color: AppColors.muted,
                      fontSize: 8.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.p8),

              // Sync Queue Items List
              Obx(() => ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppDimensions.p8),
                    itemBuilder: (context, index) {
                      final item = controller.items[index];
                      return _buildSyncRow(item);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.p8,
          vertical: AppDimensions.p12,
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
          children: [
            Text(
              value,
              style: AppTypography.displayMedium.copyWith(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.hudTicker.copyWith(
                color: AppColors.subtle,
                fontSize: 8.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.hudTicker.copyWith(
            color: AppColors.subtle,
            fontSize: 8.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSyncRow(SyncQueueItem item) {
    Color statusColor;
    Color statusBg;
    String statusLabel;

    if (item.status == 'synced') {
      statusColor = AppColors.emerald;
      statusBg = AppColors.emerald.withValues(alpha: 0.1);
      statusLabel = 'SYNCED';
    } else if (item.status == 'processing') {
      statusColor = AppColors.cyan;
      statusBg = AppColors.cyan.withValues(alpha: 0.1);
      statusLabel = 'AI PROCESSING';
    } else {
      statusColor = const Color(0xFFFF9100);
      statusBg = const Color(0xFFFF9100).withValues(alpha: 0.1);
      statusLabel = 'AWAITING CONN.';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.p12,
        vertical: AppDimensions.p12,
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
          SizedBox(
            width: 48,
            child: Text(
              item.id,
              style: AppTypography.monoTag.copyWith(
                color: AppColors.subtle,
                fontSize: 9,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTypography.displayMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item.loc,
                  style: AppTypography.monoTag.copyWith(
                    color: AppColors.subtle,
                    fontSize: 8.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              item.size,
              style: AppTypography.hudTicker.copyWith(
                color: AppColors.subtle,
                fontSize: 9,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.p8,
              vertical: AppDimensions.p4,
            ),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(AppDimensions.r6),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  statusLabel,
                  style: AppTypography.hudTicker.copyWith(
                    color: statusColor,
                    fontSize: 7.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
