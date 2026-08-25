import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/values/app_assets.dart';
import '../../../core/values/app_dimensions.dart';
import '../../../core/values/app_strings.dart';
import '../../../core/utils/responsive_util.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.litho,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.splashRadialGradient,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    maxWidth: constraints.maxWidth,
                  ),
                  child: Padding(
                    padding: AppDimensions.screenPadding,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: AppDimensions.p24),
                        // Center Hero & Logo Group
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _TechLogoWidget(),
                            const SizedBox(height: AppDimensions.p24),
                            // Wordmark
                            Text(
                              AppStrings.appName,
                              style: AppTypography.displayLarge.copyWith(
                                fontSize: context.isSmallScreen ? 26 : 32,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppDimensions.p6),
                            // Tagline
                            Text(
                              AppStrings.appTagline,
                              style: AppTypography.monoSubtitle.copyWith(
                                fontSize: context.isSmallScreen ? 9 : 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppDimensions.p40),
                            // Status HUD Ticker
                            const _HudStatusTicker(),
                            const SizedBox(height: AppDimensions.p16),
                            // Progress Bar
                            const _ProgressBar(),
                          ],
                        ),
                        // Version Footer
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppDimensions.p16),
                          child: Text(
                            AppStrings.appVersion,
                            style: AppTypography.monoFooter,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TechLogoWidget extends StatefulWidget {
  const _TechLogoWidget();

  @override
  State<_TechLogoWidget> createState() => _TechLogoWidgetState();
}

class _TechLogoWidgetState extends State<_TechLogoWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = context.isSmallScreen ? 120 : 144;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer subtle glowing aura ring
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.ore.withValues(alpha: 0.25),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ore.withValues(alpha: 0.1),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          // Rotating outer tech ticks
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: CustomPaint(
                  size: Size(size, size),
                  painter: const _TechRingPainter(),
                ),
              );
            },
          ),
          // App Logo Image
          Image.asset(
            AppAssets.logo,
            width: size * 0.65,
            height: size * 0.65,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: size * 0.65,
                height: size * 0.65,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface2,
                ),
                child: const Icon(
                  Icons.diamond_outlined,
                  color: AppColors.ore,
                  size: 40,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TechRingPainter extends CustomPainter {
  const _TechRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double radius = (size.width / 2) - 4;

    final circlePaint = Paint()
      ..color = AppColors.ore.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(Offset(cx, cy), radius, circlePaint);

    final tickPaint = Paint()
      ..color = AppColors.ore.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final double angle = (i * 45) * math.pi / 180;
      final double startX = cx + (radius - 2) * math.cos(angle);
      final double startY = cy + (radius - 2) * math.sin(angle);
      final double endX = cx + (radius - 8) * math.cos(angle);
      final double endY = cy + (radius - 8) * math.sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HudStatusTicker extends StatelessWidget {
  const _HudStatusTicker();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SplashController>();
    return Obx(() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            controller.currentStepText,
            style: AppTypography.hudTicker,
          ),
          const SizedBox(width: 2),
          const _BlinkingCursor(),
        ],
      );
    });
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Text(
        '_',
        style: AppTypography.hudTicker.copyWith(
          color: AppColors.cyan,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SplashController>();
    return Container(
      width: 200,
      height: 3,
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppDimensions.rFull),
      ),
      child: Obx(() {
        return Align(
          alignment: Alignment.centerLeft,
          child: AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            widthFactor: controller.progress.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(AppDimensions.rFull),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ore.withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
