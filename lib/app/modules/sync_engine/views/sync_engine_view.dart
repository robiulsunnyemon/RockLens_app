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
        child: GetBuilder<SyncEngineController>(
          builder: (controller) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.p10),

              // 1. Header with Offline/Online Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sync Engine',
                    style: AppTypography.displayMedium.copyWith(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Obx(() {
                    final offline = controller.isOfflineMode.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.p8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: offline
                            ? AppColors.ember.withValues(alpha: 0.12)
                            : AppColors.emerald.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppDimensions.r8),
                        border: Border.all(
                          color: offline
                              ? AppColors.ember.withValues(alpha: 0.35)
                              : AppColors.emerald.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: offline ? AppColors.ember : AppColors.emerald,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            offline ? 'OFFLINE' : 'CLOUD READY',
                            style: AppTypography.hudTicker.copyWith(
                              color: offline ? AppColors.ember : AppColors.emerald,
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: AppDimensions.p12),

              // 2. Status Summary (3 Metric Cards)
              Obx(() => Row(
                    children: [
                      _buildSummaryCard(
                        label: 'PENDING',
                        value: '${controller.pendingCount.value}',
                        color: const Color(0xFFFF9100),
                      ),
                      const SizedBox(width: AppDimensions.p8),
                      _buildSummaryCard(
                        label: 'QUEUED SIZE',
                        value: controller.queuedSizeFormatted.value,
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
              const SizedBox(height: AppDimensions.p12),

              // 3. Controls Card (Cellular Toggle + Force Sync Button)
              Container(
                padding: const EdgeInsets.all(AppDimensions.p14),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cellular Data Sync',
                                style: AppTypography.displayMedium.copyWith(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Use mobile network when WiFi is unavailable',
                                style: AppTypography.hudTicker.copyWith(
                                  color: AppColors.subtle,
                                  fontSize: 9,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
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
                    const SizedBox(height: AppDimensions.p10),

                    // Dynamic Sync / Up-to-date Button
                    Obx(() {
                      final syncing = controller.isSyncing.value;
                      final hasPending = controller.pendingCount.value > 0;
                      final hasItems = controller.items.isNotEmpty;

                      Color bgColor;
                      Color fgColor;
                      Color borderColor;

                      if (syncing) {
                        bgColor = AppColors.surface;
                        fgColor = AppColors.ore;
                        borderColor = AppColors.ore.withValues(alpha: 0.4);
                      } else if (hasPending) {
                        bgColor = AppColors.ore;
                        fgColor = AppColors.litho;
                        borderColor = Colors.transparent;
                      } else if (hasItems) {
                        bgColor = AppColors.emerald.withValues(alpha: 0.12);
                        fgColor = AppColors.emerald;
                        borderColor = AppColors.emerald.withValues(alpha: 0.35);
                      } else {
                        bgColor = AppColors.surface;
                        fgColor = AppColors.subtle;
                        borderColor = AppColors.surfaceBorder;
                      }

                      return SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: syncing ? null : controller.forceBackgroundSync,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bgColor,
                            foregroundColor: fgColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.r12),
                              side: BorderSide(color: borderColor),
                            ),
                            elevation: 0,
                          ),
                          child: syncing
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.ore),
                                      ),
                                    ),
                                    const SizedBox(width: AppDimensions.p8),
                                    Text(
                                      'Uploading Batch to Cloud...',
                                      style: AppTypography.buttonText.copyWith(
                                        color: AppColors.ore,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      hasPending
                                          ? Icons.cloud_upload_outlined
                                          : hasItems
                                              ? Icons.check_circle_outline_rounded
                                              : Icons.cloud_done_outlined,
                                      size: 16,
                                      color: fgColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      hasPending
                                          ? 'Force Background Sync (${controller.pendingCount.value})'
                                          : hasItems
                                              ? 'All Scans Synchronized ✓'
                                              : 'No Scans in Queue',
                                      style: AppTypography.buttonText.copyWith(
                                        color: fgColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.p12),

              // 4. Legend
              Row(
                children: [
                  _buildLegendDot(color: AppColors.emerald, label: 'SYNCED'),
                  const SizedBox(width: AppDimensions.p12),
                  _buildLegendDot(color: AppColors.cyan, label: 'AI PROCESSING'),
                  const SizedBox(width: AppDimensions.p12),
                  _buildLegendDot(color: const Color(0xFFFF9100), label: 'AWAITING CONN.'),
                ],
              ),
              const SizedBox(height: AppDimensions.p10),

              // 5. Sync Table Header
              Row(
                children: [
                  SizedBox(
                    width: 65,
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
              const SizedBox(height: AppDimensions.p6),

              // 6. SCROLLABLE QUEUE LIST
              Expanded(
                child: Obx(() {
                  final queue = controller.items;
                  if (queue.isEmpty) {
                    return Center(
                      child: Text(
                        'No field scans in queue.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.muted),
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: AppDimensions.p16),
                    itemCount: queue.length,
                    separatorBuilder: (_, index) => const SizedBox(height: AppDimensions.p8),
                    itemBuilder: (context, idx) {
                      final item = queue[idx];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.p12,
                          vertical: AppDimensions.p10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.surfaceBorder,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // ID
                            SizedBox(
                              width: 65,
                              child: Text(
                                item.id,
                                style: AppTypography.monoTag.copyWith(
                                  color: AppColors.quartz,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Mineral & Location
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    item.loc,
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
                            // Size
                            SizedBox(
                              width: 55,
                              child: Text(
                                item.size,
                                style: AppTypography.hudTicker.copyWith(
                                  color: AppColors.subtle,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                            // Status Badge
                            _buildStatusBadge(item.status),
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
                fontSize: 16.5,
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.hudTicker.copyWith(
            color: AppColors.subtle,
            fontSize: 7.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case 'synced':
        bg = AppColors.emerald.withValues(alpha: 0.15);
        fg = AppColors.emerald;
        text = 'SYNCED';
        break;
      case 'processing':
        bg = AppColors.cyan.withValues(alpha: 0.15);
        fg = AppColors.cyan;
        text = 'AI PROCESSING';
        break;
      case 'pending':
      default:
        bg = const Color(0xFFFF9100).withValues(alpha: 0.15);
        fg = const Color(0xFFFF9100);
        text = 'AWAITING CONN.';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: fg.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        text,
        style: AppTypography.hudTicker.copyWith(
          color: fg,
          fontSize: 7.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
