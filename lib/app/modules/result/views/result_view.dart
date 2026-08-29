import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/values/app_dimensions.dart';
import '../controllers/result_controller.dart';

class ResultView extends GetView<ResultController> {
  const ResultView({super.key});

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
          'GEOLOGICAL IDENTIFICATION',
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
            // Explicit Neural Inference Error Banner
            Obx(() {
              if (!controller.hasError.value) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(bottom: AppDimensions.p16),
                padding: const EdgeInsets.all(AppDimensions.p16),
                decoration: BoxDecoration(
                  color: const Color(0xFF331111),
                  borderRadius: AppDimensions.radius16,
                  border: Border.all(color: Colors.redAccent, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'DINOv2 INFERENCE EXECUTION FAILED',
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.errorMessage.value,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: controller.discardAndScanAgain,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('RE-SCAN SPECIMEN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Low Confidence / Out-Of-Distribution Warning Banner
            Obx(() {
              if (controller.hasError.value || !controller.isLowConfidence.value) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(bottom: AppDimensions.p16),
                padding: const EdgeInsets.all(AppDimensions.p14),
                decoration: BoxDecoration(
                  color: const Color(0xFF332611),
                  borderRadius: AppDimensions.radius16,
                  border: Border.all(color: Colors.amberAccent, width: 1.2),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.amberAccent, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LOW CONFIDENCE / UNKNOWN OBJECT (<35%)',
                            style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.6),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'The scanned surface does not strongly match known mineral crystalline textures (e.g. keyboard, household item, or poor lighting). Showing closest match.',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            // Hero ID Card with Radial Confidence Gauge
            Container(
              padding: const EdgeInsets.all(AppDimensions.p16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface,
                    AppColors.surface2,
                  ],
                ),
                borderRadius: AppDimensions.radius24,
                border: Border.all(
                  color: AppColors.ore.withValues(alpha: 0.25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Mineral Captured Photo Preview / Color Swatch
                  Obx(() {
                    final photoPath = controller.capturedPhotoPath.value;
                    final hasValidPhoto = photoPath != null &&
                        photoPath.isNotEmpty &&
                        File(photoPath).existsSync();

                    return Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A4A2E), Color(0xFF2D7A4A)],
                        ),
                        borderRadius: AppDimensions.radius16,
                        border: Border.all(
                          color: AppColors.emerald.withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                      ),
                      child: hasValidPhoto
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(AppDimensions.r16 - 1.2),
                              child: Image.file(
                                File(photoPath),
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => const Icon(
                                  Icons.diamond_outlined,
                                  color: AppColors.emerald,
                                  size: 30,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.diamond_outlined,
                              color: AppColors.emerald,
                              size: 30,
                            ),
                    );
                  }),
                  const SizedBox(width: AppDimensions.p14),

                  // Name & Formula
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Text(
                              controller.mineralGroup.value,
                              style: AppTypography.hudTicker.copyWith(
                                color: AppColors.emerald,
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            )),
                        const SizedBox(height: 2),
                        Obx(() => Text(
                              controller.mineralName.value,
                              style: AppTypography.displayLarge.copyWith(
                                color: AppColors.quartz,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                        const SizedBox(height: 2),
                        Obx(() => Text(
                              controller.chemicalFormula.value,
                              style: AppTypography.monoSubtitle.copyWith(
                                color: AppColors.ore,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            )),
                      ],
                    ),
                  ),

                  // Radial Confidence Gauge
                  Obx(() => _ConfidenceGaugeWidget(
                        value: controller.confidencePercentage.value.round(),
                      )),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.p16),

            // 6 Properties Grid
            Obx(() {
              final entries = controller.properties.entries.toList();
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppDimensions.p8,
                  mainAxisSpacing: AppDimensions.p8,
                  childAspectRatio: 2.2,
                ),
                itemCount: entries.length,
                itemBuilder: (context, idx) {
                  final prop = entries[idx];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimensions.r12),
                      border: Border.all(color: AppColors.surfaceBorder, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          prop.key,
                          style: AppTypography.hudTicker.copyWith(
                            color: AppColors.subtle,
                            fontSize: 7.5,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          prop.value,
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.quartz,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
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
            const SizedBox(height: AppDimensions.p16),

            // Commercial Valuation Card
            Container(
              padding: const EdgeInsets.all(AppDimensions.p16),
              decoration: BoxDecoration(
                color: AppColors.ore.withValues(alpha: 0.06),
                borderRadius: AppDimensions.radius16,
                border: Border.all(
                  color: AppColors.ore.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COMMERCIAL ESTIMATE',
                    style: AppTypography.hudTicker.copyWith(
                      color: AppColors.ore,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.p12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RAW ORE GRADE',
                              style: AppTypography.hudTicker.copyWith(
                                color: AppColors.muted,
                                fontSize: 8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Obx(() => Text(
                                  controller.rawOreEstimate.value,
                                  style: AppTypography.displayMedium.copyWith(
                                    color: AppColors.ore,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            Text(
                              'LME Cu ref. basis',
                              style: AppTypography.monoFooter.copyWith(
                                color: AppColors.subtle,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: AppColors.surfaceBorder,
                      ),
                      const SizedBox(width: AppDimensions.p16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SPECIMEN GRADE',
                              style: AppTypography.hudTicker.copyWith(
                                color: AppColors.muted,
                                fontSize: 8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Obx(() => Text(
                                  controller.specimenEstimate.value,
                                  style: AppTypography.displayMedium.copyWith(
                                    color: AppColors.emerald,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            Text(
                              'Crystal quality',
                              style: AppTypography.monoFooter.copyWith(
                                color: AppColors.subtle,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.p16),

            // Alternative Candidates
            Text(
              'ALTERNATIVE CANDIDATES',
              style: AppTypography.hudTicker.copyWith(
                color: AppColors.muted,
                fontSize: 9,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: AppDimensions.p8),
            Obx(() => Row(
                  children: controller.alternativeCandidates.map((alt) {
                    final colorHex = alt['color'] as String? ?? '#00E5FF';
                    final color = Color(int.parse(colorHex.replaceAll('#', '0xFF')));
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.r12),
                          border: Border.all(color: AppColors.surfaceBorder, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alt['name'] as String,
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.quartz,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${alt['pct']}% MATCH',
                              style: AppTypography.hudTicker.copyWith(
                                color: color,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                )),
            const SizedBox(height: AppDimensions.p24),

            // Action Buttons
            // 1. Refine with Field Test
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: controller.goToFieldTest,
                icon: const Icon(Icons.tune_rounded, size: 18, color: AppColors.cyan),
                label: Text(
                  'Refine with Field Test (Recommended) +10%',
                  style: AppTypography.buttonText.copyWith(
                    color: AppColors.cyan,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan.withValues(alpha: 0.1),
                  side: BorderSide(color: AppColors.cyan.withValues(alpha: 0.4), width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.radius16,
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.p10),

            // 2. Confirm & Log and Discard
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: controller.confirmAndLog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ore,
                        foregroundColor: AppColors.litho,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDimensions.radius16,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Confirm & Log',
                        style: AppTypography.buttonText.copyWith(
                          color: AppColors.litho,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.p10),
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: controller.discardAndScanAgain,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.surfaceBorder, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppDimensions.radius16,
                      ),
                    ),
                    child: Text(
                      'Discard',
                      style: AppTypography.hudTicker.copyWith(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.p20),
          ],
        ),
      ),
    );
  }
}

class _ConfidenceGaugeWidget extends StatelessWidget {
  final int value;
  const _ConfidenceGaugeWidget({required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(76, 76),
            painter: _GaugePainter(percentage: value / 100.0),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$value%',
                style: AppTypography.displayLarge.copyWith(
                  color: AppColors.ore,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'MATCH',
                style: AppTypography.hudTicker.copyWith(
                  color: AppColors.subtle,
                  fontSize: 7,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percentage;
  const _GaugePainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Background track
    final bgPaint = Paint()
      ..color = AppColors.surfaceBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    canvas.drawCircle(center, radius, bgPaint);

    // Active Arc
    final activePaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.oreDark, AppColors.ore],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.0;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * percentage,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.percentage != percentage;
}
