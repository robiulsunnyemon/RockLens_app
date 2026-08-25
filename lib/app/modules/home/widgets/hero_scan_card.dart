import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/values/app_dimensions.dart';

class HeroScanCard extends StatefulWidget {
  final VoidCallback onTap;

  const HeroScanCard({super.key, required this.onTap});

  @override
  State<HeroScanCard> createState() => _HeroScanCardState();
}

class _HeroScanCardState extends State<HeroScanCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.p24,
              horizontal: AppDimensions.p16,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E2330), Color(0xFF181C24)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppDimensions.radius24,
              border: Border.all(
                color: AppColors.ore.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ore.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: AppDimensions.radius24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Reticle Icon Area
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer Ring Pulse
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.ore.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                        ),
                        // Inner Ring
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.ore.withValues(alpha: 0.08),
                            border: Border.all(
                              color: AppColors.ore.withValues(alpha: 0.6),
                              width: 1,
                            ),
                          ),
                        ),
                        // Center Crosshair
                        const Icon(
                          Icons.center_focus_strong_rounded,
                          color: AppColors.ore,
                          size: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.p12),

                    // Title
                    Text(
                      'INITIATE SCAN',
                      style: AppTypography.displayMedium.copyWith(
                        color: AppColors.ore,
                        fontSize: 18,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p4),

                    // Subtitle Tag
                    Text(
                      'OTZAR AI MINERAL IDENTIFICATION · OFFLINE READY',
                      style: AppTypography.hudTicker.copyWith(
                        color: AppColors.subtle,
                        fontSize: 9.5,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
