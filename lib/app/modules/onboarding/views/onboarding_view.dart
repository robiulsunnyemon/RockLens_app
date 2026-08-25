import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/values/app_assets.dart';
import '../../../core/values/app_dimensions.dart';
import '../../../core/values/app_strings.dart';
import '../../../core/utils/responsive_util.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.litho,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.p20,
                vertical: AppDimensions.p12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo + App Name
                  Row(
                    children: [
                      Image.asset(
                        AppAssets.logo,
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.diamond_outlined, color: AppColors.ore, size: 24),
                      ),
                      const SizedBox(width: AppDimensions.p8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStrings.appName,
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.ore,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            AppStrings.appSubtag,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Skip button
                  TextButton(
                    onPressed: controller.skip,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.p12,
                        vertical: AppDimensions.p6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      AppStrings.skip,
                      style: AppTypography.hudTicker.copyWith(
                        color: AppColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page View (Carousel)
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.slides.length,
                itemBuilder: (context, index) {
                  final slide = controller.slides[index];
                  return _SlideContent(slide: slide);
                },
              ),
            ),

            // Bottom Navigation & CTA Section
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.p24,
                AppDimensions.p8,
                AppDimensions.p24,
                AppDimensions.p24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dot Indicators
                  Obx(() {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.slides.length,
                        (i) => GestureDetector(
                          onTap: () => controller.goToSlide(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: controller.currentIndex.value == i ? 22 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: controller.currentIndex.value == i
                                  ? AppColors.ore
                                  : AppColors.surface2,
                              borderRadius: BorderRadius.circular(AppDimensions.rFull),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: AppDimensions.p24),

                  // CTA Button
                  Obx(() {
                    return Container(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: AppDimensions.radius16,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.ore.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: controller.next,
                          borderRadius: AppDimensions.radius16,
                          child: Center(
                            child: Text(
                              controller.isLastSlide
                                  ? AppStrings.accessSystemBtn
                                  : AppStrings.continueBtn,
                              style: AppTypography.buttonText,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideContent extends StatelessWidget {
  final OnboardingSlideModel slide;

  const _SlideContent({required this.slide});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: AppDimensions.p16),
                  // Illustration Graphic
                  _SlideIllustration(index: slide.slideIndex),
                  const SizedBox(height: AppDimensions.p24),

                  // Tag badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.p12,
                      vertical: AppDimensions.p6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.goldSubtle,
                      borderRadius: AppDimensions.radius8,
                      border: Border.all(
                        color: AppColors.ore.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      slide.tag,
                      style: AppTypography.monoTag,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.p16),

                  // Title
                  Text(
                    slide.title,
                    style: AppTypography.displayMedium.copyWith(
                      fontSize: context.isSmallScreen ? 20 : 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.p12),

                  // Description
                  Text(
                    slide.description,
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: context.isSmallScreen ? 13 : 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.p16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SlideIllustration extends StatelessWidget {
  final int index;

  const _SlideIllustration({required this.index});

  @override
  Widget build(BuildContext context) {
    final double size = context.isSmallScreen ? 140 : 160;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(
          color: _getAccentColor().withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _getAccentColor().withValues(alpha: 0.08),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.55, size * 0.55),
          painter: _SlidePainter(index: index),
        ),
      ),
    );
  }

  Color _getAccentColor() {
    switch (index) {
      case 0:
        return AppColors.ore;
      case 1:
        return AppColors.cyan;
      case 2:
      default:
        return AppColors.emerald;
    }
  }
}

class _SlidePainter extends CustomPainter {
  final int index;

  const _SlidePainter({required this.index});

  @override
  void paint(Canvas canvas, Size size) {
    if (index == 0) {
      _paintCameraReticle(canvas, size);
    } else if (index == 1) {
      _paintOfflineVault(canvas, size);
    } else {
      _paintGisMap(canvas, size);
    }
  }

  void _paintCameraReticle(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ore
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = AppColors.ore.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    // Camera Body Box
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.2, size.width * 0.8, size.height * 0.65),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, fillPaint);
    canvas.drawRRect(rect, paint);

    // Lens
    final lensCenter = Offset(size.width * 0.5, size.height * 0.525);
    canvas.drawCircle(lensCenter, size.width * 0.2, fillPaint);
    canvas.drawCircle(lensCenter, size.width * 0.2, paint);
    canvas.drawCircle(
      lensCenter,
      size.width * 0.07,
      Paint()
        ..color = AppColors.ore
        ..style = PaintingStyle.fill,
    );

    // Top flash notch
    final flashRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.4, size.height * 0.12, size.width * 0.2, size.height * 0.1),
      const Radius.circular(2),
    );
    canvas.drawRRect(flashRect, Paint()..color = AppColors.ore);
  }

  void _paintOfflineVault(Canvas canvas, Size size) {
    final cyanPaint = Paint()
      ..color = AppColors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Document Card
    final docRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.1, size.width * 0.6, size.height * 0.75),
      const Radius.circular(6),
    );
    canvas.drawRRect(docRect, fillPaint);
    canvas.drawRRect(docRect, cyanPaint);

    // Document lines
    final linePaint = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.4)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(size.width * 0.25, size.height * 0.25),
        Offset(size.width * 0.6, size.height * 0.25), linePaint);
    canvas.drawLine(Offset(size.width * 0.25, size.height * 0.38),
        Offset(size.width * 0.55, size.height * 0.38), linePaint);
    canvas.drawLine(Offset(size.width * 0.25, size.height * 0.5),
        Offset(size.width * 0.45, size.height * 0.5), linePaint);

    // Success Check Badge
    final badgeCenter = Offset(size.width * 0.75, size.height * 0.75);
    canvas.drawCircle(
      badgeCenter,
      size.width * 0.2,
      Paint()..color = AppColors.surface,
    );
    canvas.drawCircle(
      badgeCenter,
      size.width * 0.2,
      Paint()
        ..color = AppColors.emerald
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    final checkPaint = Paint()
      ..color = AppColors.emerald
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(badgeCenter.dx - 6, badgeCenter.dy)
      ..lineTo(badgeCenter.dx - 2, badgeCenter.dy + 4)
      ..lineTo(badgeCenter.dx + 6, badgeCenter.dy - 4);
    canvas.drawPath(path, checkPaint);
  }

  void _paintGisMap(Canvas canvas, Size size) {
    final emeraldPaint = Paint()
      ..color = AppColors.emerald
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = AppColors.emerald.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Outer claim boundary polygon
    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.3)
      ..lineTo(size.width * 0.85, size.height * 0.2)
      ..lineTo(size.width * 0.9, size.height * 0.75)
      ..lineTo(size.width * 0.3, size.height * 0.85)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, emeraldPaint);

    // Topographic contour line
    final contourPaint = Paint()
      ..color = AppColors.emerald.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final contourPath = Path()
      ..moveTo(size.width * 0.2, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.35,
        size.width * 0.8,
        size.height * 0.55,
      );
    canvas.drawPath(contourPath, contourPaint);

    // Claim Nodes (Gold Points)
    final nodePaint = Paint()
      ..color = AppColors.ore
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.45), 4, nodePaint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.5), 4, nodePaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.68), 3, Paint()..color = AppColors.emerald);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
