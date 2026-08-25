import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/values/app_assets.dart';
import '../../../core/values/app_dimensions.dart';
import '../controllers/scanner_controller.dart';

class ScannerView extends GetView<ScannerController> {
  const ScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Camera Viewport & HUD
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Live Camera Preview Feed
                  Obx(() {
                    if (controller.isCameraInitialized.value && controller.cameraController != null) {
                      return ClipRect(
                        child: SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: controller.cameraController!.value.previewSize?.height ?? 1,
                              height: controller.cameraController!.value.previewSize?.width ?? 1,
                              child: CameraPreview(
                                controller.cameraController!,
                                key: ValueKey(controller.cameraController!.hashCode),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    // Simulated rock terrain gradient & noise background if camera unavailable
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1A1408),
                            Color(0xFF0D1108),
                            Color(0xFF0A0D14),
                            Color(0xFF130D08),
                          ],
                        ),
                      ),
                    );
                  }),

                  // Grid Lines Overlay
                  CustomPaint(
                    painter: _ScannerGridPainter(),
                  ),

                  // Top Telemetry HUD Bar
                  Positioned(
                    top: AppDimensions.p16,
                    left: AppDimensions.p16,
                    right: AppDimensions.p16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left telemetry
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() => Text(
                                  'ELV  ${controller.elevation.value}',
                                  style: AppTypography.hudTicker.copyWith(
                                    color: AppColors.cyan,
                                    fontSize: 9.5,
                                  ),
                                )),
                            const SizedBox(height: 2),
                            Obx(() => Text(
                                  'BRG  ${controller.bearing.value}',
                                  style: AppTypography.hudTicker.copyWith(
                                    color: AppColors.cyan,
                                    fontSize: 9.5,
                                  ),
                                )),
                          ],
                        ),

                        // Center HUD Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.p8,
                            vertical: AppDimensions.p4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(AppDimensions.r8),
                            border: Border.all(
                              color: AppColors.ore.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                AppAssets.logo,
                                width: 14,
                                height: 14,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.diamond_outlined, color: AppColors.ore, size: 14),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'OTZAR APP HUD',
                                style: AppTypography.hudTicker.copyWith(
                                  color: AppColors.ore,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Right coordinates
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Obx(() => Text(
                                  controller.latitude.value,
                                  style: AppTypography.hudTicker.copyWith(
                                    color: AppColors.cyan,
                                    fontSize: 9.5,
                                  ),
                                )),
                            const SizedBox(height: 2),
                            Obx(() => Text(
                                  controller.longitude.value,
                                  style: AppTypography.hudTicker.copyWith(
                                    color: AppColors.cyan,
                                    fontSize: 9.5,
                                  ),
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Central Mineral Reticle Bounding Box
                  Center(
                    child: SizedBox(
                      width: 250,
                      height: 220,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 4 Corner Brackets
                          ..._buildReticleCorners(),

                          // Inner Dashed Mineral Detection Box
                          Positioned.fill(
                            child: Container(
                              margin: const EdgeInsets.all(AppDimensions.p24),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.ore.withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // Label Tag
                                  Positioned(
                                    top: -12,
                                    left: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      color: AppColors.ore.withValues(alpha: 0.15),
                                      child: Text(
                                        'MINERAL DETECTED',
                                        style: AppTypography.hudTicker.copyWith(
                                          color: AppColors.ore,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Crosshairs & Center target
                                  Center(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 1,
                                          color: AppColors.ore.withValues(alpha: 0.6),
                                        ),
                                        Container(
                                          width: 1,
                                          height: 28,
                                          color: AppColors.ore.withValues(alpha: 0.6),
                                        ),
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.ore.withValues(alpha: 0.3),
                                            border: Border.all(color: AppColors.ore, width: 1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Center Dot
                          Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.ore,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),

                          // Live Detection Chip Below Reticle
                          Positioned(
                            bottom: -28,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Obx(() {
                                final isScanning = controller.isScanning.value;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isScanning
                                        ? AppColors.ore.withValues(alpha: 0.18)
                                        : AppColors.emerald.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(AppDimensions.r4),
                                    border: Border.all(
                                      color: isScanning
                                          ? AppColors.ore.withValues(alpha: 0.5)
                                          : AppColors.emerald.withValues(alpha: 0.35),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    controller.detectionStatusText,
                                    style: AppTypography.hudTicker.copyWith(
                                      color: isScanning ? AppColors.ore : AppColors.emerald,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Laser Scan Line Animation when capturing
                  Obx(() {
                    if (!controller.isScanning.value) return const SizedBox.shrink();
                    return const _ScanLineLaser();
                  }),

                  // Torch Light Toggle Button (Bottom Left)
                  Positioned(
                    bottom: 24,
                    left: AppDimensions.p16,
                    child: Obx(() {
                      final torch = controller.isTorchOn.value;
                      return GestureDetector(
                        onTap: controller.toggleTorch,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: torch
                                ? AppColors.ore.withValues(alpha: 0.25)
                                : AppColors.surface.withValues(alpha: 0.8),
                            border: Border.all(
                              color: torch ? AppColors.ore : AppColors.surfaceBorder,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            torch ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                            color: torch ? AppColors.ore : AppColors.muted,
                            size: 20,
                          ),
                        ),
                      );
                    }),
                  ),

                  // Scale Reference Badge (Bottom Right - Tap to Cycle)
                  Positioned(
                    bottom: 24,
                    right: AppDimensions.p16,
                    child: GestureDetector(
                      onTap: controller.cycleScaleReference,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(AppDimensions.r8),
                          border: Border.all(
                            color: AppColors.ore.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'SCALE REF',
                                  style: AppTypography.hudTicker.copyWith(
                                    color: AppColors.muted,
                                    fontSize: 7.5,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.touch_app_outlined, color: AppColors.muted, size: 9),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.ore.withValues(alpha: 0.3),
                                    border: Border.all(color: AppColors.ore, width: 1),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Obx(() => Text(
                                      controller.currentScale.name,
                                      style: AppTypography.hudTicker.copyWith(
                                        color: AppColors.ore,
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Controls Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p20, vertical: AppDimensions.p16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.95),
                border: const Border(
                  top: BorderSide(color: AppColors.surfaceBorder, width: 1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mode Switcher (SINGLE SHOT vs BURST MODE)
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(AppDimensions.r12),
                    ),
                    child: Obx(() {
                      final currentMode = controller.scanMode.value;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildModeButton(
                            title: 'SINGLE SHOT',
                            isSelected: currentMode == ScanMode.single,
                            onTap: () => controller.setMode(ScanMode.single),
                          ),
                          _buildModeButton(
                            title: 'BURST MODE',
                            isSelected: currentMode == ScanMode.burst,
                            onTap: () => controller.setMode(ScanMode.burst),
                          ),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: AppDimensions.p16),

                  // Bottom Action Bar: Gallery, Torch, Shutter, Switch Camera, Back
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gallery Picker Button
                      IconButton(
                        onPressed: controller.pickFromGallery,
                        icon: const Icon(Icons.photo_library_outlined),
                        color: AppColors.cyan,
                        iconSize: 22,
                        tooltip: 'Upload from Gallery',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface2,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),

                      // Torch / Flash Toggle Button
                      Obx(() => IconButton(
                            onPressed: controller.toggleTorch,
                            icon: Icon(
                              controller.isTorchOn.value
                                  ? Icons.flashlight_on_rounded
                                  : Icons.flashlight_off_rounded,
                            ),
                            color: controller.isTorchOn.value ? AppColors.ore : AppColors.muted,
                            iconSize: 22,
                            tooltip: 'Toggle Flashlight',
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surface2,
                              padding: const EdgeInsets.all(12),
                            ),
                          )),

                      // Animated Shutter Trigger
                      Obx(() {
                        final isScanning = controller.isScanning.value;
                        return GestureDetector(
                          onTap: controller.captureAndAnalyze,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isScanning
                                  ? AppColors.ore.withValues(alpha: 0.3)
                                  : Colors.transparent,
                              border: Border.all(
                                color: AppColors.ore,
                                width: 3.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.ore.withValues(alpha: 0.35),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isScanning
                                      ? AppColors.ore.withValues(alpha: 0.4)
                                      : AppColors.ore,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),

                      // Switch Front/Rear Camera Button
                      IconButton(
                        onPressed: controller.switchCamera,
                        icon: const Icon(Icons.cameraswitch_outlined),
                        color: AppColors.muted,
                        iconSize: 22,
                        tooltip: 'Switch Camera',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface2,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),

                      // Back Button
                      IconButton(
                        onPressed: controller.goBack,
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.muted,
                        iconSize: 22,
                        tooltip: 'Close Scanner',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface2,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p16, vertical: AppDimensions.p8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.ore : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.r8),
        ),
        child: Text(
          title,
          style: AppTypography.hudTicker.copyWith(
            color: isSelected ? AppColors.litho : AppColors.muted,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildReticleCorners() {
    const size = 20.0;
    const thickness = 2.5;

    return [
      // Top Left
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.ore, width: thickness),
              left: BorderSide(color: AppColors.ore, width: thickness),
            ),
          ),
        ),
      ),
      // Top Right
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.ore, width: thickness),
              right: BorderSide(color: AppColors.ore, width: thickness),
            ),
          ),
        ),
      ),
      // Bottom Left
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.ore, width: thickness),
              left: BorderSide(color: AppColors.ore, width: thickness),
            ),
          ),
        ),
      ),
      // Bottom Right
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.ore, width: thickness),
              right: BorderSide(color: AppColors.ore, width: thickness),
            ),
          ),
        ),
      ),
    ];
  }
}

class _ScannerGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.1)
      ..strokeWidth = 0.5;

    // Vertical lines
    canvas.drawLine(Offset(size.width / 3, 0), Offset(size.width / 3, size.height), paint);
    canvas.drawLine(Offset(size.width * 2 / 3, 0), Offset(size.width * 2 / 3, size.height), paint);

    // Horizontal lines
    canvas.drawLine(Offset(0, size.height / 3), Offset(size.width, size.height / 3), paint);
    canvas.drawLine(Offset(0, size.height * 2 / 3), Offset(size.width, size.height * 2 / 3), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanLineLaser extends StatefulWidget {
  const _ScanLineLaser();

  @override
  State<_ScanLineLaser> createState() => _ScanLineLaserState();
}

class _ScanLineLaserState extends State<_ScanLineLaser> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
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
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.2 +
              (MediaQuery.of(context).size.height * 0.4 * _anim.value),
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.ore,
                  AppColors.cyan,
                  AppColors.ore,
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ore.withValues(alpha: 0.8),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
