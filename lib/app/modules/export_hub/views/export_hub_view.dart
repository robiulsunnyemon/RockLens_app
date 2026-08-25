import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/values/app_dimensions.dart';
import '../controllers/export_hub_controller.dart';

class ExportHubView extends GetView<ExportHubController> {
  const ExportHubView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.litho,
      appBar: AppBar(
        backgroundColor: AppColors.litho,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.quartz),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'GEOLOGICAL EXPORT HUB',
          style: AppTypography.displayMedium.copyWith(
            color: AppColors.quartz,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p16, vertical: AppDimensions.p8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Survey Preview Card
            Container(
              padding: const EdgeInsets.all(AppDimensions.p16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.surface, AppColors.surface2],
                ),
                borderRadius: AppDimensions.radius24,
                border: Border.all(
                  color: AppColors.ore.withValues(alpha: 0.25),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OTZAR APP FIELD REPORT',
                    style: AppTypography.hudTicker.copyWith(
                      color: AppColors.ore,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Zambia Copperbelt Survey',
                    style: AppTypography.displayLarge.copyWith(
                      color: AppColors.quartz,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Dr. K. Osei · West Africa Survey Unit · Aug 2026',
                    style: AppTypography.monoFooter.copyWith(
                      color: AppColors.muted,
                      fontSize: 9.5,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.p14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatBadge('6', 'Specimens'),
                      _buildStatBadge('4', 'Minerals'),
                      _buildStatBadge('3', 'Locations'),
                      _buildStatBadge('91%', 'Avg Conf.'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.p16),

            // Date Range Switcher (24h, 7d, 30d, All)
            Text(
              'DATE RANGE',
              style: AppTypography.hudTicker.copyWith(
                color: AppColors.muted,
                fontSize: 9,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: AppDimensions.p8),
            Row(
              children: ['24h', '7d', '30d', 'All'].map((range) {
                return Expanded(
                  child: Obx(() {
                    final isSel = controller.selectedDateRange.value == range;
                    return GestureDetector(
                      onTap: () => controller.setDateRange(range),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.ore : AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.r10),
                          border: Border.all(
                            color: isSel ? AppColors.ore : AppColors.surfaceBorder,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            range,
                            style: AppTypography.hudTicker.copyWith(
                              color: isSel ? AppColors.litho : AppColors.muted,
                              fontSize: 10.5,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.p16),

            // Export Formats List (PDF, KML, CSV, GeoJSON)
            Text(
              'EXPORT FORMATS',
              style: AppTypography.hudTicker.copyWith(
                color: AppColors.muted,
                fontSize: 9,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: AppDimensions.p8),
            Column(
              children: ExportHubController.formats.map((f) {
                final formatColor = Color(f.colorHex);
                return Obx(() {
                  final isSel = controller.selectedFormats.contains(f.id);
                  return GestureDetector(
                    onTap: () => controller.toggleFormat(f.id),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(AppDimensions.p12),
                      decoration: BoxDecoration(
                        color: isSel
                            ? formatColor.withValues(alpha: 0.08)
                            : AppColors.surface,
                        borderRadius: AppDimensions.radius16,
                        border: Border.all(
                          color: isSel ? formatColor.withValues(alpha: 0.4) : AppColors.surfaceBorder,
                          width: isSel ? 1.2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: formatColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppDimensions.r12),
                            ),
                            child: Icon(
                              f.id == 'pdf'
                                  ? Icons.picture_as_pdf_outlined
                                  : f.id == 'kml'
                                      ? Icons.map_outlined
                                      : f.id == 'csv'
                                          ? Icons.table_chart_outlined
                                          : Icons.data_object_outlined,
                              color: formatColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.p12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  f.name,
                                  style: AppTypography.titleLarge.copyWith(
                                    color: AppColors.quartz,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  f.desc,
                                  style: AppTypography.monoFooter.copyWith(
                                    color: AppColors.muted,
                                    fontSize: 8.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: isSel ? formatColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(AppDimensions.r4),
                                  border: Border.all(
                                    color: isSel ? formatColor : AppColors.surfaceBorder,
                                    width: 1.5,
                                  ),
                                ),
                                child: isSel
                                    ? const Icon(Icons.check, size: 14, color: AppColors.litho)
                                    : null,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                f.size,
                                style: AppTypography.monoFooter.copyWith(
                                  color: AppColors.subtle,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                });
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.p24),

            // Export Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(() {
                final count = controller.selectedFormats.length;
                final exporting = controller.isExporting.value;

                return ElevatedButton(
                  onPressed: count == 0 || exporting ? null : controller.exportSelected,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ore,
                    foregroundColor: AppColors.litho,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimensions.radius16,
                    ),
                    elevation: 0,
                  ),
                  child: exporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.litho),
                          ),
                        )
                      : Text(
                          'Export $count Format${count != 1 ? 's' : ''}',
                          style: AppTypography.buttonText.copyWith(
                            color: AppColors.litho,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                );
              }),
            ),
            const SizedBox(height: AppDimensions.p20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: AppTypography.displayLarge.copyWith(
            color: AppColors.ore,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.monoFooter.copyWith(
            color: AppColors.muted,
            fontSize: 8,
          ),
        ),
      ],
    );
  }
}
