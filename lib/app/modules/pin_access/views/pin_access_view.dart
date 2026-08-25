import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/values/app_assets.dart';
import '../../../core/values/app_dimensions.dart';
import '../../../core/values/app_strings.dart';
import '../controllers/pin_access_controller.dart';

class PinAccessView extends GetView<PinAccessController> {
  const PinAccessView({super.key});

  static const List<String> _keys = [
    '1', '2', '3',
    '4', '5', '6',
    '7', '8', '9',
    '', '0', '⌫',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.litho,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.surface, AppColors.litho],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    maxWidth: constraints.maxWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.p24,
                      vertical: AppDimensions.p16,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Header Section
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Top Bar with Back Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: AppColors.muted,
                                    size: 18,
                                  ),
                                  onPressed: controller.changeEmail,
                                  tooltip: 'Back to Operator Email',
                                ),
                                const SizedBox(width: 40),
                              ],
                            ),
                            // Logo Box
                            Container(
                              width: 56,
                              height: 56,
                              padding: const EdgeInsets.all(AppDimensions.p10),
                              decoration: BoxDecoration(
                                color: AppColors.goldSubtle,
                                borderRadius: AppDimensions.radius16,
                                border: Border.all(
                                  color: AppColors.ore.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.ore.withValues(alpha: 0.15),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                AppAssets.logo,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.diamond_outlined, color: AppColors.ore, size: 30),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.p12),

                            // Title
                            Text(
                              AppStrings.fieldAccess,
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.quartz,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.p4),

                            // Subtitle
                            Text(
                              AppStrings.secureLogin,
                              style: AppTypography.monoSubtitle.copyWith(
                                fontSize: 9.5,
                                color: AppColors.muted,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            // Active Operator Email Pill
                            Obx(() {
                              final email = controller.operatorEmail.value;
                              if (email == null) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: AppDimensions.p8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.p10,
                                    vertical: AppDimensions.p4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface2,
                                    borderRadius: BorderRadius.circular(AppDimensions.rFull),
                                    border: Border.all(
                                      color: AppColors.ore.withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.person_outline_rounded,
                                        color: AppColors.ore,
                                        size: 12,
                                      ),
                                      const SizedBox(width: AppDimensions.p4),
                                      Text(
                                        email,
                                        style: AppTypography.monoFooter.copyWith(
                                          color: AppColors.quartz,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),

                        // PIN Input Dots & Hint Section
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: AppDimensions.p16),
                            const _PinDotsIndicator(),
                            const SizedBox(height: AppDimensions.p16),
                            Text(
                              AppStrings.pinHint,
                              style: AppTypography.monoFooter.copyWith(
                                color: AppColors.subtle,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),

                        // Keypad Section
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _KeypadGrid(keys: _keys),
                            const SizedBox(height: AppDimensions.p12),

                            // Conditional Action: Resend PIN (Unverified) or Reset PIN (Verified)
                            Obx(() {
                              final isVerified = controller.isVerified.value;
                              final loading = controller.isLoading.value;

                              if (!isVerified) {
                                return TextButton.icon(
                                  onPressed: loading ? null : controller.resendPin,
                                  icon: const Icon(
                                    Icons.refresh_rounded,
                                    size: 15,
                                    color: AppColors.ore,
                                  ),
                                  label: Text(
                                    'Resend 4-Digit Security PIN',
                                    style: AppTypography.hudTicker.copyWith(
                                      color: AppColors.ore,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                );
                              } else {
                                return TextButton.icon(
                                  onPressed: loading ? null : controller.resetPin,
                                  icon: const Icon(
                                    Icons.lock_reset_rounded,
                                    size: 15,
                                    color: AppColors.subtle,
                                  ),
                                  label: Text(
                                    'Forgot Security PIN? Reset PIN →',
                                    style: AppTypography.hudTicker.copyWith(
                                      color: AppColors.subtle,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }
                            }),
                            const SizedBox(height: AppDimensions.p12),
                          ],
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

class _PinDotsIndicator extends StatelessWidget {
  const _PinDotsIndicator();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PinAccessController>();
    return Obx(() {
      final pinLength = controller.pin.value.length;
      final isShaking = controller.isShaking.value;

      return _ShakeWrapper(
        isShaking: isShaking,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final isFilled = index < pinLength;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: AppDimensions.p8),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled ? AppColors.ore : Colors.transparent,
                border: Border.all(
                  color: isFilled ? AppColors.ore : AppColors.subtle,
                  width: 2,
                ),
                boxShadow: isFilled
                    ? [
                        BoxShadow(
                          color: AppColors.ore.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
            );
          }),
        ),
      );
    });
  }
}

class _ShakeWrapper extends StatefulWidget {
  final bool isShaking;
  final Widget child;

  const _ShakeWrapper({required this.isShaking, required this.child});

  @override
  State<_ShakeWrapper> createState() => _ShakeWrapperState();
}

class _ShakeWrapperState extends State<_ShakeWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didUpdateWidget(covariant _ShakeWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShaking && !oldWidget.isShaking) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double offset = math.sin(_controller.value * math.pi * 6) * 12 * (1 - _controller.value);
        return Transform.translate(
          offset: Offset(offset, 0),
          child: widget.child,
        );
      },
    );
  }
}

class _KeypadGrid extends StatelessWidget {
  final List<String> keys;

  const _KeypadGrid({required this.keys});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PinAccessController>();
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: keys.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppDimensions.p12,
          mainAxisSpacing: AppDimensions.p12,
          childAspectRatio: 1.35,
        ),
        itemBuilder: (context, index) {
          final key = keys[index];
          if (key.isEmpty) {
            return const SizedBox.shrink();
          }

          return Material(
            color: AppColors.surface,
            borderRadius: AppDimensions.radius16,
            child: InkWell(
              onTap: () => controller.onKeyPressed(key),
              borderRadius: AppDimensions.radius16,
              splashColor: AppColors.ore.withValues(alpha: 0.15),
              highlightColor: AppColors.surface2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: AppDimensions.radius16,
                  border: Border.all(
                    color: AppColors.surface2,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  key,
                  style: key == '⌫'
                      ? AppTypography.hudTicker.copyWith(
                          fontSize: 18,
                          color: AppColors.muted,
                        )
                      : AppTypography.keypadDigit,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
