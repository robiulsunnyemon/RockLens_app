import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/values/app_dimensions.dart';
import '../controllers/gis_map_controller.dart';
import '../widgets/gis_map_painter.dart';

class GisMapView extends GetView<GisMapController> {
  const GisMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.litho,
      body: SafeArea(
        child: Stack(
          children: [
            // Map Canvas
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      // GIS Map Custom Painter
                      Obx(() => CustomPaint(
                            size: Size(constraints.maxWidth, constraints.maxHeight),
                            painter: GisMapPainter(
                              showHeatmap: controller.isHeatmapActive.value,
                            ),
                          )),

                      // Interactive Pin Markers
                      ...controller.pins.map((pin) {
                        return Obx(() {
                          final isSelected = controller.selectedPin.value?.id == pin.id;
                          final color = Color(pin.colorHex);

                          return Positioned(
                            left: constraints.maxWidth * pin.xRatio - 20,
                            top: constraints.maxHeight * pin.yRatio - 20,
                            child: GestureDetector(
                              onTap: () => controller.selectPin(pin),
                              child: Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Outer Ripple Halo
                                    Container(
                                      width: isSelected ? 36 : 28,
                                      height: isSelected ? 36 : 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: color.withValues(alpha: isSelected ? 0.25 : 0.12),
                                        border: Border.all(
                                          color: color.withValues(alpha: 0.4),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    // Core Pin Circle
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected ? color : color.withValues(alpha: 0.8),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: color.withValues(alpha: 0.5),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${pin.id}',
                                          style: TextStyle(
                                            color: isSelected ? AppColors.litho : Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                      }),
                    ],
                  );
                },
              ),
            ),

            // Top Header Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.p16,
                  vertical: AppDimensions.p10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.litho.withValues(alpha: 0.95),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'GIS Claim Map',
                      style: AppTypography.displayMedium.copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        // Heatmap toggle
                        Obx(() {
                          final active = controller.isHeatmapActive.value;
                          return ElevatedButton(
                            onPressed: controller.toggleHeatmap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: active
                                  ? AppColors.emerald.withValues(alpha: 0.2)
                                  : AppColors.surface,
                              foregroundColor:
                                  active ? AppColors.emerald : AppColors.subtle,
                              side: BorderSide(
                                color: active
                                    ? AppColors.emerald.withValues(alpha: 0.5)
                                    : AppColors.surfaceBorder,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.p10,
                                vertical: AppDimensions.p6,
                              ),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppDimensions.r10),
                              ),
                            ),
                            child: Text(
                              'HEATMAP',
                              style: AppTypography.hudTicker.copyWith(
                                color: active ? AppColors.emerald : AppColors.subtle,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                        const SizedBox(width: AppDimensions.p8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.p10,
                            vertical: AppDimensions.p6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppDimensions.r10),
                            border: Border.all(
                              color: AppColors.surfaceBorder,
                            ),
                          ),
                          child: Text(
                            'LAYERS',
                            style: AppTypography.hudTicker.copyWith(
                              color: AppColors.subtle,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Live GPS Coordinates HUD Badge
            Positioned(
              top: 56,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.p8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.litho.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(AppDimensions.r6),
                  border: Border.all(
                    color: AppColors.cyan.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  '-12.9783°S · 028.6234°E',
                  style: AppTypography.hudTicker.copyWith(
                    color: AppColors.cyan,
                    fontSize: 8.5,
                  ),
                ),
              ),
            ),

            // Bottom Selected Pin Drawer Card
            Obx(() {
              final pin = controller.selectedPin.value;
              final isOpen = controller.isDrawerOpen.value;

              if (pin == null || !isOpen) return const SizedBox.shrink();

              final color = Color(pin.colorHex);

              return Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.p16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppDimensions.radius24,
                    border: Border.all(
                      color: AppColors.surfaceBorder,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.7),
                        blurRadius: 30,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header & Close
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius:
                                      BorderRadius.circular(AppDimensions.r10),
                                  border: Border.all(
                                    color: color.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Center(
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pin.name,
                                    style: AppTypography.displayMedium.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${pin.conf}% MATCH',
                                    style: AppTypography.hudTicker.copyWith(
                                      color: color,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.muted,
                              size: 18,
                            ),
                            onPressed: controller.toggleDrawer,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.p12),

                      // Metrics 3 Columns
                      Row(
                        children: [
                          _buildDrawerMetric(
                            label: 'BEARING',
                            value: pin.bearing,
                          ),
                          const SizedBox(width: AppDimensions.p6),
                          _buildDrawerMetric(
                            label: 'ELEVATION',
                            value: pin.elevation,
                          ),
                          const SizedBox(width: AppDimensions.p6),
                          _buildDrawerMetric(
                            label: 'DATE',
                            value: pin.date,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerMetric({
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.p8,
          vertical: AppDimensions.p8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF252B3A),
          borderRadius: BorderRadius.circular(AppDimensions.r10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.hudTicker.copyWith(
                color: AppColors.subtle,
                fontSize: 8,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTypography.hudTicker.copyWith(
                color: AppColors.quartz,
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
