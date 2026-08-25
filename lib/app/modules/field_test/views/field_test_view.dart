import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/values/app_dimensions.dart';
import '../controllers/field_test_controller.dart';

class FieldTestView extends GetView<FieldTestController> {
  const FieldTestView({super.key});

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
          'FIELD OBSERVATION TEST',
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
            // Confidence Boost Banner
            Obx(() {
              final isAdjusted = controller.isAdjusted;
              final newConf = controller.calculatedConfidence.round();
              final diff = (newConf - controller.baseConfidence.value).round();

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p16, vertical: AppDimensions.p14),
                decoration: BoxDecoration(
                  color: isAdjusted
                      ? AppColors.emerald.withValues(alpha: 0.1)
                      : AppColors.surface,
                  borderRadius: AppDimensions.radius16,
                  border: Border.all(
                    color: isAdjusted
                        ? AppColors.emerald.withValues(alpha: 0.4)
                        : AppColors.surfaceBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CONFIDENCE ADJUSTED',
                          style: AppTypography.hudTicker.copyWith(
                            color: AppColors.muted,
                            fontSize: 8.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${controller.baseConfidence.value.round()}% → $newConf%',
                          style: AppTypography.displayLarge.copyWith(
                            color: isAdjusted ? AppColors.emerald : AppColors.quartz,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAdjusted
                            ? AppColors.emerald.withValues(alpha: 0.2)
                            : AppColors.surface2,
                        borderRadius: BorderRadius.circular(AppDimensions.r8),
                      ),
                      child: Row(
                        children: [
                          if (isAdjusted)
                            const Icon(Icons.arrow_upward_rounded, size: 14, color: AppColors.emerald),
                          Text(
                            isAdjusted ? '+$diff%' : 'Adjust below',
                            style: AppTypography.hudTicker.copyWith(
                              color: isAdjusted ? AppColors.emerald : AppColors.muted,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: AppDimensions.p16),

            // Mohs Hardness Scale Slider
            Container(
              padding: const EdgeInsets.all(AppDimensions.p16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppDimensions.radius16,
                border: Border.all(color: AppColors.surfaceBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MOHS HARDNESS SCALE',
                        style: AppTypography.hudTicker.copyWith(
                          color: AppColors.ore,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Obx(() => Text(
                            '${controller.mohs.value.toStringAsFixed(1)} — ${controller.nearestReference.label}',
                            style: AppTypography.titleLarge.copyWith(
                              color: AppColors.quartz,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.p10),

                  // Interactive Slider
                  Obx(() => SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppColors.ore,
                          inactiveTrackColor: AppColors.surfaceBorder,
                          thumbColor: AppColors.ore,
                          overlayColor: AppColors.ore.withValues(alpha: 0.2),
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        ),
                        child: Slider(
                          value: controller.mohs.value,
                          min: 1.0,
                          max: 10.0,
                          divisions: 18,
                          onChanged: controller.setMohs,
                        ),
                      )),
                  const SizedBox(height: AppDimensions.p4),

                  // Reference Ticks
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: FieldTestController.mohsReferences.map((ref) {
                      return Obx(() {
                        final isPassed = controller.mohs.value >= ref.value;
                        return Column(
                          children: [
                            Container(
                              width: 3,
                              height: 10,
                              decoration: BoxDecoration(
                                color: isPassed ? AppColors.ore : AppColors.surfaceBorder,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${ref.value}',
                              style: AppTypography.monoFooter.copyWith(
                                color: AppColors.subtle,
                                fontSize: 8,
                              ),
                            ),
                            Text(
                              ref.label,
                              style: AppTypography.monoFooter.copyWith(
                                color: isPassed ? AppColors.quartz : AppColors.subtle,
                                fontSize: 7,
                              ),
                            ),
                          ],
                        );
                      });
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.p16),

            // Streak Plate Test (6 Tiles)
            Container(
              padding: const EdgeInsets.all(AppDimensions.p16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppDimensions.radius16,
                border: Border.all(color: AppColors.surfaceBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STREAK PLATE TEST',
                    style: AppTypography.hudTicker.copyWith(
                      color: AppColors.ore,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.p12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: AppDimensions.p8,
                      mainAxisSpacing: AppDimensions.p8,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: FieldTestController.streakColors.length,
                    itemBuilder: (context, idx) {
                      final item = FieldTestController.streakColors[idx];
                      return Obx(() {
                        final isSelected = controller.streak.value == item.name;
                        return GestureDetector(
                          onTap: () => controller.setStreak(item.name),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.ore.withValues(alpha: 0.12)
                                  : AppColors.surface2,
                              borderRadius: BorderRadius.circular(AppDimensions.r12),
                              border: Border.all(
                                color: isSelected ? AppColors.ore : AppColors.surfaceBorder,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(item.colorHex),
                                    border: Border.all(
                                      color: Color(item.borderHex),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.name,
                                  style: AppTypography.hudTicker.copyWith(
                                    color: isSelected ? AppColors.ore : AppColors.muted,
                                    fontSize: 8.5,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.p16),

            // Magnetism & Acid Reaction Grid
            Row(
              children: [
                // Magnetism Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.p14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppDimensions.radius16,
                      border: Border.all(color: AppColors.surfaceBorder, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MAGNETISM',
                          style: AppTypography.hudTicker.copyWith(
                            color: AppColors.ore,
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.p8),
                        ...['Non-Magnetic', 'Weak', 'Strong'].map((m) {
                          return Obx(() {
                            final isSel = controller.magnetism.value == m;
                            return GestureDetector(
                              onTap: () => controller.setMagnetism(m),
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? AppColors.cyan.withValues(alpha: 0.12)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(AppDimensions.r6),
                                  border: Border.all(
                                    color: isSel
                                        ? AppColors.cyan.withValues(alpha: 0.4)
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Text(
                                  m,
                                  style: AppTypography.hudTicker.copyWith(
                                    color: isSel ? AppColors.cyan : AppColors.subtle,
                                    fontSize: 9,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          });
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.p10),

                // Acid Reaction Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.p14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppDimensions.radius16,
                      border: Border.all(color: AppColors.surfaceBorder, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACID REACTION',
                          style: AppTypography.hudTicker.copyWith(
                            color: AppColors.ore,
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.p8),
                        ...['None', 'Slight', 'Effervescent'].map((a) {
                          return Obx(() {
                            final isSel = controller.acidReaction.value == a;
                            return GestureDetector(
                              onTap: () => controller.setAcidReaction(a),
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? AppColors.emerald.withValues(alpha: 0.12)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(AppDimensions.r6),
                                  border: Border.all(
                                    color: isSel
                                        ? AppColors.emerald.withValues(alpha: 0.4)
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Text(
                                  a,
                                  style: AppTypography.hudTicker.copyWith(
                                    color: isSel ? AppColors.emerald : AppColors.subtle,
                                    fontSize: 9,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          });
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.p24),

            // Update Analysis Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.updateAndReturn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ore,
                      foregroundColor: AppColors.litho,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppDimensions.radius16,
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Update Analysis → ${controller.calculatedConfidence.round()}% Confidence',
                      style: AppTypography.buttonText.copyWith(
                        color: AppColors.litho,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
            ),
            const SizedBox(height: AppDimensions.p20),
          ],
        ),
      ),
    );
  }
}
