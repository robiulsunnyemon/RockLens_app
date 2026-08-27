import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/values/app_dimensions.dart';
import '../../../core/widgets/otzar_cached_image.dart';
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
            // 1. Map Canvas & Interactive Pins
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      // GIS Map Custom Painter with Contours, Faults, and Grid
                      Obx(() => CustomPaint(
                            size: Size(constraints.maxWidth, constraints.maxHeight),
                            painter: GisMapPainter(
                              showHeatmap: controller.isHeatmapActive.value,
                            ),
                          )),

                      // Live User "MY LOCATION" Radar Ping (Center-left)
                      Positioned(
                        left: constraints.maxWidth * 0.22 - 12,
                        top: constraints.maxHeight * 0.45 - 12,
                        child: Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.cyan.withValues(alpha: 0.2),
                                  border: Border.all(color: AppColors.cyan, width: 1),
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.cyan,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Dynamic Specimen & Concession Pins
                      Obx(() {
                        final pins = controller.filteredPins;
                        return Stack(
                          children: pins.map((pin) {
                            final isSelected = controller.selectedPin.value?.id == pin.id;
                            final color = Color(pin.colorHex);

                            return Positioned(
                              left: (constraints.maxWidth * pin.xRatio - 20).clamp(8.0, constraints.maxWidth - 48.0),
                              top: (constraints.maxHeight * pin.yRatio - 20).clamp(70.0, constraints.maxHeight - 160.0),
                              child: GestureDetector(
                                onTap: () => controller.selectPin(pin),
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  alignment: Alignment.center,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Outer Ripple Halo
                                      Container(
                                        width: isSelected ? 38 : 28,
                                        height: isSelected ? 38 : 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: color.withValues(alpha: isSelected ? 0.3 : 0.12),
                                          border: Border.all(
                                            color: color.withValues(alpha: 0.5),
                                            width: isSelected ? 1.5 : 1,
                                          ),
                                        ),
                                      ),
                                      // Core Pin Circle
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected ? color : color.withValues(alpha: 0.85),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: color.withValues(alpha: 0.6),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Icon(
                                            pin.isUserDiscovery ? Icons.person_pin_circle_rounded : Icons.diamond_outlined,
                                            color: isSelected ? AppColors.litho : Colors.white,
                                            size: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),

            // 2. Top Header Bar & Controls
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
                        fontSize: 18,
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
                              foregroundColor: active ? AppColors.emerald : AppColors.subtle,
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
                                borderRadius: BorderRadius.circular(AppDimensions.r10),
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

                        // Layers Filter Button
                        GestureDetector(
                          onTap: () => _showLayersBottomSheet(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.p10,
                              vertical: AppDimensions.p6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppDimensions.r10),
                              border: Border.all(
                                color: AppColors.surfaceBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.layers_outlined, color: AppColors.ore, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  'LAYERS',
                                  style: AppTypography.hudTicker.copyWith(
                                    color: AppColors.subtle,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 3. Live GPS Coordinates HUD Badge
            Positioned(
              top: 56,
              left: 16,
              child: Obx(() => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.p8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.litho.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(AppDimensions.r6),
                      border: Border.all(
                        color: AppColors.cyan.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.gps_fixed_rounded, color: AppColors.cyan, size: 10),
                        const SizedBox(width: 4),
                        Text(
                          controller.userGpsFormatted.value,
                          style: AppTypography.hudTicker.copyWith(
                            color: AppColors.cyan,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )),
            ),

            // 4. Bottom Selected Pin Drawer Card or Empty Radar State
            Obx(() {
              final pins = controller.filteredPins;
              final pin = controller.selectedPin.value;
              final isOpen = controller.isDrawerOpen.value;

              if (pins.isEmpty) {
                return Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.92),
                      borderRadius: AppDimensions.radius16,
                      border: Border.all(
                        color: AppColors.surfaceBorder,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.ore.withValues(alpha: 0.12),
                          ),
                          child: const Icon(Icons.radar_rounded, color: AppColors.ore, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'NO FIELD CLAIMS RECORDED',
                                style: AppTypography.hudTicker.copyWith(
                                  color: AppColors.quartz,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Scan and log mineral specimens with GPS to drop interactive field claim pins.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.subtle,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (pin == null || !isOpen) {
                return Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      if (pin != null) {
                        controller.isDrawerOpen.value = true;
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.92),
                        borderRadius: AppDimensions.radius16,
                        border: Border.all(
                          color: AppColors.surfaceBorder,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 16,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.explore_outlined, color: AppColors.ore, size: 16),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    pin != null
                                        ? 'TAP TO EXPAND: ${pin.name.toUpperCase()}'
                                        : 'TAP ANY PIN ON MAP TO INSPECT',
                                    style: AppTypography.hudTicker.copyWith(
                                      color: AppColors.subtle,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_up_rounded, color: AppColors.ore, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final color = Color(pin.colorHex);
              final dist = controller.calculateDistanceTo(pin);
              final brg = controller.calculateBearingTo(pin);

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
                          Expanded(
                            child: Row(
                              children: [
                                // Thumbnail or Specimen Badge
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(AppDimensions.r10),
                                    border: Border.all(
                                      color: color.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: pin.photoPath != null
                                      ? OtzarCachedImage(
                                          imageUrlOrPath: pin.photoPath!,
                                          fit: BoxFit.cover,
                                          borderRadius: BorderRadius.circular(AppDimensions.r10 - 1),
                                          errorWidget: Center(
                                            child: Icon(Icons.diamond_outlined, color: color, size: 18),
                                          ),
                                        )
                                      : Center(
                                          child: Icon(Icons.diamond_outlined, color: color, size: 18),
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
                                              pin.name,
                                              style: AppTypography.displayMedium.copyWith(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (pin.isUserDiscovery) ...[
                                            const SizedBox(width: 5),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: AppColors.ore.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(3),
                                              ),
                                              child: Text(
                                                'SCAN',
                                                style: AppTypography.monoFooter.copyWith(
                                                  color: AppColors.ore,
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${pin.conf}% MATCH · ${pin.locationName}',
                                        style: AppTypography.hudTicker.copyWith(
                                          color: color,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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

                      // Metrics 3 Columns (Bearing/Distance, Altitude, Date)
                      Row(
                        children: [
                          _buildDrawerMetric(
                            label: 'BEARING',
                            value: '$brg · $dist',
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

  void _showLayersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.r20)),
      ),
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p20, vertical: AppDimensions.p16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GIS MAP LAYERS & FILTERS',
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.ore,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.p12),
                Obx(() => ListTile(
                      leading: const Icon(Icons.public_rounded, color: AppColors.cyan),
                      title: const Text('All Deposits & Scans', style: TextStyle(color: AppColors.quartz, fontSize: 13)),
                      trailing: controller.currentFilter.value == MapLayerFilter.all
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.ore)
                          : null,
                      onTap: () {
                        controller.setFilter(MapLayerFilter.all);
                        Get.back();
                      },
                    )),
                Obx(() => ListTile(
                      leading: const Icon(Icons.person_pin_circle_outlined, color: AppColors.emerald),
                      title: const Text('My Discovery Scans Only', style: TextStyle(color: AppColors.quartz, fontSize: 13)),
                      trailing: controller.currentFilter.value == MapLayerFilter.myScans
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.ore)
                          : null,
                      onTap: () {
                        controller.setFilter(MapLayerFilter.myScans);
                        Get.back();
                      },
                    )),
                Obx(() => ListTile(
                      leading: const Icon(Icons.terrain_rounded, color: Color(0xFFFF9100)),
                      title: const Text('African Mining Reserves', style: TextStyle(color: AppColors.quartz, fontSize: 13)),
                      trailing: controller.currentFilter.value == MapLayerFilter.africanMines
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.ore)
                          : null,
                      onTap: () {
                        controller.setFilter(MapLayerFilter.africanMines);
                        Get.back();
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}
