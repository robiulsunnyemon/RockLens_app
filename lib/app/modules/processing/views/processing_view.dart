import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/values/app_assets.dart';
import '../../../core/values/app_dimensions.dart';
import '../controllers/processing_controller.dart';

class ProcessingView extends GetView<ProcessingController> {
  const ProcessingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.litho,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 3D Rotating Rings & Holographic Mineral Crystal
                const _HolographicRingWidget(),
                const SizedBox(height: AppDimensions.p24),

                // Top Engine Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.rFull),
                    border: Border.all(
                      color: AppColors.ore.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        AppAssets.logo,
                        width: 16,
                        height: 16,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.diamond_outlined, color: AppColors.ore, size: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'OTZAR APP NEURAL ENGINE',
                        style: AppTypography.hudTicker.copyWith(
                          color: AppColors.ore,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.p16),

                // Title & Subtitle
                Text(
                  'Neural Analysis in Progress',
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.quartz,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ON-DEVICE TFLITE INFERENCE · OFFLINE MODE',
                  style: AppTypography.monoSubtitle.copyWith(
                    color: AppColors.muted,
                    fontSize: 9.5,
                  ),
                ),
                const SizedBox(height: AppDimensions.p24),

                // Progress Bar (0% to 100%)
                SizedBox(
                  width: 240,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'INFERENCE',
                            style: AppTypography.hudTicker.copyWith(
                              color: AppColors.subtle,
                              fontSize: 8.5,
                            ),
                          ),
                          Obx(() => Text(
                                '${controller.progress.value}%',
                                style: AppTypography.hudTicker.copyWith(
                                  color: AppColors.ore,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimensions.rFull),
                        child: Container(
                          height: 5,
                          color: AppColors.surfaceBorder,
                          child: Obx(() => FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: controller.progress.value / 100.0,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.oreDark,
                                        AppColors.ore,
                                        AppColors.cyan,
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.p24),

                // Live Neural Console Stream Box
                Container(
                  width: double.infinity,
                  height: 170,
                  padding: const EdgeInsets.all(AppDimensions.p14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppDimensions.radius16,
                    border: Border.all(color: AppColors.surfaceBorder, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.emerald,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'INFERENCE ENGINE OUTPUT',
                            style: AppTypography.hudTicker.copyWith(
                              color: AppColors.cyan,
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Obx(() {
                          final lines = controller.consoleLines;
                          return ListView.builder(
                            itemCount: lines.length + 1,
                            itemBuilder: (context, idx) {
                              if (idx == lines.length) {
                                return Text(
                                  '> _',
                                  style: AppTypography.hudTicker.copyWith(
                                    color: AppColors.ore,
                                    fontSize: 9,
                                  ),
                                );
                              }
                              final isLast = idx == lines.length - 1;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text(
                                  '> ${lines[idx]}',
                                  style: AppTypography.hudTicker.copyWith(
                                    color: isLast ? AppColors.ore : AppColors.subtle,
                                    fontSize: 9,
                                    fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.p24),

                // 4-Step Indicators: Capture -> Analyze -> Identify -> Log
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStepDot(1, 'Capture', isDone: true, isActive: false),
                    _buildStepLine(isDone: true),
                    _buildStepDot(2, 'Analyze', isDone: false, isActive: true),
                    _buildStepLine(isDone: false),
                    _buildStepDot(3, 'Identify', isDone: false, isActive: false),
                    _buildStepLine(isDone: false),
                    _buildStepDot(4, 'Log', isDone: false, isActive: false),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepDot(int step, String label, {required bool isDone, required bool isActive}) {
    return Column(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isDone || isActive) ? AppColors.ore : AppColors.surfaceBorder,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 13, color: AppColors.litho)
                : Text(
                    '$step',
                    style: AppTypography.hudTicker.copyWith(
                      color: isActive ? AppColors.litho : AppColors.muted,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.hudTicker.copyWith(
            color: (isDone || isActive) ? AppColors.quartz : AppColors.subtle,
            fontSize: 7.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine({required bool isDone}) {
    return Container(
      width: 20,
      height: 1.5,
      margin: const EdgeInsets.only(bottom: 12),
      color: isDone ? AppColors.ore : AppColors.surfaceBorder,
    );
  }
}

class _HolographicRingWidget extends StatefulWidget {
  const _HolographicRingWidget();

  @override
  State<_HolographicRingWidget> createState() => _HolographicRingWidgetState();
}

class _HolographicRingWidgetState extends State<_HolographicRingWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return SizedBox(
          width: 150,
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer rotating ring
              Transform.rotate(
                angle: _anim.value * 2 * 3.14159,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.cyan.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // Inner reverse rotating ring
              Transform.rotate(
                angle: -_anim.value * 2 * 3.14159,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.ore.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // Central Crystal Silhouette
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.emerald.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.emerald.withValues(alpha: 0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.emerald.withValues(alpha: 0.3),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.diamond_outlined,
                  color: AppColors.emerald,
                  size: 28,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
