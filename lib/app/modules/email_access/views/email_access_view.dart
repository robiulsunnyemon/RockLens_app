import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/values/app_assets.dart';
import '../../../core/values/app_dimensions.dart';
import '../../../core/values/app_strings.dart';
import '../controllers/email_access_controller.dart';

class EmailAccessView extends GetView<EmailAccessController> {
  const EmailAccessView({super.key});

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
                        // 1. Top Header Section
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: AppDimensions.p12),
                            // Logo badge
                            Container(
                              width: 60,
                              height: 60,
                              padding: const EdgeInsets.all(AppDimensions.p10),
                              decoration: BoxDecoration(
                                color: AppColors.goldSubtle,
                                borderRadius: AppDimensions.radius16,
                                border: Border.all(
                                  color: AppColors.ore.withValues(alpha: 0.35),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.ore.withValues(alpha: 0.18),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                AppAssets.logo,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.diamond_outlined, color: AppColors.ore, size: 32),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.p16),

                            // Header Titles
                            Text(
                              AppStrings.emailAccessTitle,
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.quartz,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.p6),
                            Text(
                              AppStrings.emailAccessSubtitle,
                              style: AppTypography.monoSubtitle.copyWith(
                                fontSize: 9.5,
                                color: AppColors.muted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),

                        // 2. Unified Input & Submit Button Card
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppDimensions.p20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Field Label
                              Text(
                                AppStrings.emailInputLabel,
                                style: AppTypography.monoTag.copyWith(
                                  color: AppColors.ore,
                                  fontSize: 10.5,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.p8),

                              // Email Input Box
                              Obx(() {
                                final hasError = controller.emailError.value != null;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: AppDimensions.radius16,
                                    border: Border.all(
                                      color: hasError
                                          ? AppColors.rust
                                          : AppColors.surface2,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: hasError
                                            ? AppColors.rust.withValues(alpha: 0.15)
                                            : AppColors.ore.withValues(alpha: 0.04),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: controller.emailTextController,
                                    onChanged: controller.onTextChanged,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => controller.submitEmail(),
                                    style: AppTypography.bodyLarge.copyWith(
                                      color: AppColors.quartz,
                                      fontSize: 15,
                                    ),
                                    cursorColor: AppColors.ore,
                                    decoration: InputDecoration(
                                      hintText: AppStrings.emailInputHint,
                                      hintStyle: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.subtle,
                                        fontSize: 14,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.mail_outline_rounded,
                                        color: AppColors.ore,
                                        size: 20,
                                      ),
                                      suffixIcon: controller.emailTextController.text.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(
                                                Icons.clear_rounded,
                                                color: AppColors.muted,
                                                size: 18,
                                              ),
                                              onPressed: () {
                                                controller.emailTextController.clear();
                                                controller.onTextChanged('');
                                              },
                                            )
                                          : null,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: AppDimensions.p16,
                                        vertical: AppDimensions.p16,
                                      ),
                                    ),
                                  ),
                                );
                              }),

                              // Error Message Display
                              Obx(() {
                                final error = controller.emailError.value;
                                if (error == null) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    top: AppDimensions.p8,
                                    left: AppDimensions.p4,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline_rounded,
                                        color: AppColors.rust,
                                        size: 14,
                                      ),
                                      const SizedBox(width: AppDimensions.p6),
                                      Text(
                                        error,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.rust,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),

                              const SizedBox(height: AppDimensions.p20),

                              // Submit Button (Placed right below input)
                              Obx(() {
                                final loading = controller.isLoading.value;
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
                                      onTap: loading ? null : controller.submitEmail,
                                      borderRadius: AppDimensions.radius16,
                                      child: Center(
                                        child: loading
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    AppColors.litho,
                                                  ),
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    AppStrings.emailSubmitBtn,
                                                    style: AppTypography.buttonText,
                                                  ),
                                                  const SizedBox(width: AppDimensions.p8),
                                                  const Icon(
                                                    Icons.arrow_forward_rounded,
                                                    color: AppColors.litho,
                                                    size: 18,
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),

                        // 3. 1-Tap Face ID Quick Login Button (When Enabled)
                        if (controller.canUseFaceId) ...[
                          Row(
                            children: [
                              const Expanded(child: Divider(color: AppColors.surfaceBorder)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(AppStrings.orUseBiometrics, style: AppTypography.hudTicker.copyWith(color: AppColors.subtle, fontSize: 9.5)),
                              ),
                              const Expanded(child: Divider(color: AppColors.surfaceBorder)),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.p16),
                          Obx(() {
                            final isAuthenticating = controller.isFaceAuthenticating.value;
                            return Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.ore.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.ore.withValues(alpha: 0.45), width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.ore.withValues(alpha: 0.12),
                                    blurRadius: 14,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: isAuthenticating ? null : controller.loginWithFaceId,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Center(
                                    child: isAuthenticating
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.ore),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.face_retouching_natural_rounded, color: AppColors.ore, size: 22),
                                              const SizedBox(width: 10),
                                              Text(
                                                AppStrings.oneTapFaceIdLogin,
                                                style: AppTypography.buttonText.copyWith(
                                                  color: AppColors.ore,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  letterSpacing: 1.1,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: AppDimensions.p16),
                        ],

                        // 4. Bottom Biometric & Security Footer
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Biometric Face ID Icon
                            GestureDetector(
                              onTap: controller.canUseFaceId ? controller.loginWithFaceId : null,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.emeraldSubtle,
                                  border: Border.all(
                                    color: AppColors.emerald.withValues(alpha: 0.35),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.emerald.withValues(alpha: 0.12),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.face_retouching_natural_rounded,
                                  color: AppColors.emerald,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.faceIdBiometricProtected,
                              style: AppTypography.monoTag.copyWith(
                                color: AppColors.emerald,
                                fontSize: 8.5,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.p12),

                            // Security Note
                            Text(
                              AppStrings.emailSecurityNote,
                              style: AppTypography.monoFooter.copyWith(
                                color: AppColors.subtle,
                                fontSize: 8.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppDimensions.p8),
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
