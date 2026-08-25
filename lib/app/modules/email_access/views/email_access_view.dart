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
                        // Top Header Section
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

                        // Form & Input Section
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppDimensions.p24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Field Label
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppStrings.emailInputLabel,
                                    style: AppTypography.monoTag.copyWith(
                                      color: AppColors.ore,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                  // Quick demo auto-fill hint
                                  GestureDetector(
                                    onTap: () {
                                      controller.emailTextController.text =
                                          'operator@otzar.geocore';
                                      controller.onTextChanged('operator@otzar.geocore');
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppDimensions.p8,
                                        vertical: AppDimensions.p2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface2,
                                        borderRadius: BorderRadius.circular(AppDimensions.r4),
                                        border: Border.all(
                                          color: AppColors.ore.withValues(alpha: 0.3),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        'DEMO EMAIL',
                                        style: AppTypography.monoFooter.copyWith(
                                          color: AppColors.oreLight,
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
                            ],
                          ),
                        ),

                        // Bottom Actions Section
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Submit Button
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
                            const SizedBox(height: AppDimensions.p16),

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
