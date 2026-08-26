import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/values/app_dimensions.dart';
import '../../../routes/app_pages.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.litho,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed Top Section (Profile Header Card)
            Padding(
              padding: const EdgeInsets.all(AppDimensions.p16),
              child: GestureDetector(
                onTap: controller.openEditProfileSheet,
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.p16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppDimensions.radius20,
                    border: Border.all(
                      color: AppColors.ore.withValues(alpha: 0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Interactive Operator Avatar
                          GestureDetector(
                            onTap: controller.openAvatarPickerSheet,
                            child: Stack(
                              children: [
                                Obx(() {
                                  final localPath = controller.userAvatarPath.value;
                                  final remoteUrl = controller.userAvatarUrl.value;
                                  final isUploading = controller.isUploadingAvatar.value;

                                  Widget avatarContent;

                                  if (localPath != null && File(localPath).existsSync()) {
                                    avatarContent = ClipOval(
                                      child: Image.file(
                                        File(localPath),
                                        width: 58,
                                        height: 58,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  } else if (remoteUrl != null && remoteUrl.isNotEmpty) {
                                    avatarContent = ClipOval(
                                      child: Image.network(
                                        remoteUrl,
                                        width: 58,
                                        height: 58,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, stack) => Center(
                                          child: Text(
                                            controller.initials,
                                            style: AppTypography.displayMedium.copyWith(
                                              color: AppColors.litho,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    avatarContent = Center(
                                      child: Text(
                                        controller.initials,
                                        style: AppTypography.displayMedium.copyWith(
                                          color: AppColors.litho,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }

                                  return Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: AppColors.goldGradient,
                                      border: Border.all(
                                        color: AppColors.ore,
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.ore.withValues(alpha: 0.25),
                                          blurRadius: 16,
                                        ),
                                      ],
                                    ),
                                    child: isUploading
                                        ? const Center(
                                            child: SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.litho),
                                              ),
                                            ),
                                          )
                                        : avatarContent,
                                  );
                                }),

                                // Small Camera Badge on Avatar
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.surface,
                                      border: Border.all(color: AppColors.ore, width: 1.2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.5),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 11,
                                      color: AppColors.ore,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppDimensions.p14),

                          // Dynamic Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Obx(() => Text(
                                            controller.fullName,
                                            style: AppTypography.displayMedium.copyWith(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                    ),
                                    const Icon(
                                      Icons.edit_outlined,
                                      color: AppColors.ore,
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Obx(() => Text(
                                      controller.designation,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.subtle,
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                Obx(() => Text(
                                      controller.companyName,
                                      style: AppTypography.monoTag.copyWith(
                                        color: AppColors.ore,
                                        fontSize: 9.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.p16),

                      // Metrics 2 Boxes (SCANS, MINERALS)
                      Obx(() => Row(
                            children: [
                              _buildMetricBox(
                                label: 'SCANS',
                                value: '${controller.dynamicScansCount.value}',
                              ),
                              const SizedBox(width: AppDimensions.p8),
                              _buildMetricBox(
                                label: 'MINERALS',
                                value: '${controller.dynamicMineralsCount.value}',
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
            ),

            // Scrollable Content (Storage & Settings)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: AppDimensions.p16,
                  right: AppDimensions.p16,
                  bottom: AppDimensions.p32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic Local Storage Gauge Card
                    GestureDetector(
                      onTap: controller.clearMediaCache,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.p16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppDimensions.radius20,
                          border: Border.all(
                            color: AppColors.surfaceBorder,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'LOCAL STORAGE',
                                  style: AppTypography.hudTicker.copyWith(
                                    color: AppColors.ore,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Obx(() {
                                  final mb = controller.dynamicStorageUsedMb.value;
                                  final usedStr = mb < 1024
                                      ? '${mb.toStringAsFixed(1)} MB'
                                      : '${(mb / 1024).toStringAsFixed(2)} GB';
                                  return Text(
                                    '$usedStr / ${(controller.dynamicStorageTotalMb.value / 1024).toStringAsFixed(1)} GB',
                                    style: AppTypography.hudTicker.copyWith(
                                      color: AppColors.subtle,
                                      fontSize: 10,
                                    ),
                                  );
                                }),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.p8),

                            // Progress Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppDimensions.rFull),
                              child: Container(
                                height: 8,
                                color: const Color(0xFF252B3A),
                                child: Obx(() => FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: controller.storagePercentage,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          gradient: AppColors.goldGradient,
                                        ),
                                      ),
                                    )),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.p6),

                            // Gauge Subtext
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(() {
                                  final pct = controller.storagePercentage * 100;
                                  final pctStr = pct < 1 ? '< 1%' : '${pct.toStringAsFixed(1)}%';
                                  return Text(
                                    '$pctStr used · Tap to clean',
                                    style: AppTypography.hudTicker.copyWith(
                                      color: AppColors.muted,
                                      fontSize: 8.5,
                                    ),
                                  );
                                }),
                                GestureDetector(
                                  onTap: controller.goToSyncEngine,
                                  child: Obx(() {
                                    final count = controller.bufferedScansCount.value;
                                    final isSynced = count == 0;
                                    final color = isSynced ? AppColors.cyan : const Color(0xFFFF9100);

                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(AppDimensions.r6),
                                        border: Border.all(
                                          color: color.withValues(alpha: 0.35),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isSynced
                                                ? Icons.cloud_done_outlined
                                                : Icons.cloud_upload_outlined,
                                            size: 10,
                                            color: color,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            isSynced
                                                ? 'VAULT SYNCHRONIZED'
                                                : '$count SCANS BUFFERED',
                                            style: AppTypography.hudTicker.copyWith(
                                              color: color,
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p16),

                    // Settings Sections
                    _buildSettingsGroup(
                      title: 'DEVICE',
                      items: [
                        _SettingsRow(
                          icon: Icons.electric_bolt_rounded,
                          title: 'Sensor Calibration',
                          subtitle: 'GPS, camera, accelerometer · Tap for Live HUD',
                          showArrow: true,
                          onTap: controller.openSensorCalibrationSheet,
                        ),
                        _SettingsRow(
                          icon: Icons.map_outlined,
                          title: 'Offline Map Downloads',
                          subtitle: 'Zambia Copperbelt · GIS Tile Packs',
                          showArrow: true,
                          onTap: controller.openOfflineMapDownloader,
                        ),
                        _SettingsRow(
                          icon: Icons.psychology_outlined,
                          title: 'Neural Model Update',
                          subtitle: 'v4.2.1 · Edge AI Classifier',
                          showArrow: true,
                          onTap: controller.openNeuralModelUpdater,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.p16),

                    _buildSettingsGroup(
                      title: 'FIELD',
                      items: [
                        _SettingsRow(
                          icon: Icons.wb_sunny_outlined,
                          title: 'Sunlight High-Contrast Mode',
                          subtitle: 'Monochrome HUD for harsh daylight',
                          toggleObs: controller.isSunlightMode,
                          onToggle: controller.toggleSunlightMode,
                        ),
                        _SettingsRow(
                          icon: Icons.mic_none_rounded,
                          title: 'Voice Field Logging',
                          subtitle: 'Hands-free geological dictation',
                          toggleObs: controller.isVoiceLogging,
                          onToggle: controller.toggleVoiceLogging,
                        ),
                        _SettingsRow(
                          icon: Icons.sync_rounded,
                          title: 'Auto Background Sync',
                          subtitle: 'Sync when WiFi detected',
                          toggleObs: controller.isAutoSync,
                          onToggle: controller.toggleAutoSync,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.p16),

                    _buildSettingsGroup(
                      title: 'ENTERPRISE',
                      items: [
                        _SettingsRow(
                          icon: Icons.lock_outline_rounded,
                          title: 'Export Permissions',
                          subtitle: 'Team lead access · Tap for Export Hub',
                          showArrow: true,
                          onTap: () => Get.toNamed(Routes.EXPORT_HUB),
                        ),
                        _SettingsRow(
                          icon: Icons.link_rounded,
                          title: 'API Integration',
                          subtitle: 'ArcGIS Enterprise · Connected',
                          showArrow: true,
                          onTap: () => Get.snackbar(
                            'ArcGIS Enterprise',
                            'Concession geological database connected via REST API.',
                            snackPosition: SnackPosition.BOTTOM,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.p16),

                    _buildSettingsGroup(
                      title: 'SUPPORT & AI DESK',
                      items: [
                        _SettingsRow(
                          icon: Icons.smart_toy_outlined,
                          title: 'Help Center & AI Geologist',
                          subtitle: 'AI assistant & live representative desk',
                          showArrow: true,
                          onTap: () => Get.toNamed(Routes.HELP_CENTER),
                        ),
                        _SettingsRow(
                          icon: Icons.shield_outlined,
                          title: 'Field Safety & Hotlines',
                          subtitle: 'Emergency dispatch & safety guidelines',
                          showArrow: true,
                          onTap: controller.openSafetyHotlinesSheet,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.p16),

                    // Account & Privacy Group
                    _buildSettingsGroup(
                      title: 'ACCOUNT & PRIVACY',
                      items: [
                        _SettingsRow(
                          icon: Icons.info_outline_rounded,
                          title: 'About',
                          subtitle: 'Otzar Field AI · v2.4.1 Build 2026.08',
                          showArrow: true,
                          onTap: controller.showAboutDialog,
                        ),
                        _SettingsRow(
                          icon: Icons.security_outlined,
                          title: 'Setting & Privacy',
                          subtitle: 'Data encryption, telemetry & policy',
                          showArrow: true,
                          onTap: controller.showPrivacyDialog,
                        ),
                        _SettingsRow(
                          icon: Icons.person_remove_outlined,
                          iconColor: AppColors.ember,
                          title: 'Account Delete Request',
                          titleColor: AppColors.ember,
                          subtitle: 'Permanent data erasure request',
                          showArrow: true,
                          onTap: controller.showDeleteAccountRequestDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.p20),

                    // Lock Field Session Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: controller.lockSession,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.ember.withValues(alpha: 0.1),
                          foregroundColor: AppColors.ember,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.r16),
                            side: BorderSide(
                              color: AppColors.ember.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        child: Text(
                          'Lock Field Session',
                          style: AppTypography.buttonText.copyWith(
                            color: AppColors.ember,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p12),

                    // Sign out text action
                    Center(
                      child: TextButton(
                        onPressed: controller.signOut,
                        child: Text(
                          'Sign Out Operator Account',
                          style: AppTypography.hudTicker.copyWith(
                            color: AppColors.subtle,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p12),

                    // Footer Info
                    Center(
                      child: Text(
                        'OTZAR APP v2.4.1 · BUILD 2026.08 · NEURAL ENGINE v4.2 · AES-256 ENCRYPTED',
                        style: AppTypography.monoFooter.copyWith(
                          color: AppColors.muted,
                          fontSize: 7.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBox({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.p8),
        decoration: BoxDecoration(
          color: AppColors.litho.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppDimensions.r12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.displayMedium.copyWith(
                color: AppColors.ore,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.hudTicker.copyWith(
                color: AppColors.muted,
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup({
    required String title,
    required List<_SettingsRow> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            title,
            style: AppTypography.hudTicker.copyWith(
              color: AppColors.muted,
              fontSize: 9,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppDimensions.radius20,
            border: Border.all(
              color: AppColors.surfaceBorder,
              width: 1,
            ),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;

              return Column(
                children: [
                  GestureDetector(
                    onTap: item.onTap,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.p16,
                        vertical: AppDimensions.p12,
                      ),
                      child: Row(
                        children: [
                          Icon(item.icon, color: item.iconColor ?? AppColors.ore, size: 20),
                          const SizedBox(width: AppDimensions.p12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: AppTypography.displayMedium.copyWith(
                                    color: item.titleColor,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  item.subtitle,
                                  style: AppTypography.hudTicker.copyWith(
                                    color: AppColors.subtle,
                                    fontSize: 9.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (item.toggleObs != null && item.onToggle != null)
                            Obx(() => Switch(
                                  value: item.toggleObs!.value,
                                  onChanged: (_) => item.onToggle!(),
                                  activeThumbColor: AppColors.ore,
                                  activeTrackColor:
                                      AppColors.ore.withValues(alpha: 0.3),
                                  inactiveThumbColor: AppColors.muted,
                                  inactiveTrackColor: AppColors.surfaceBorder,
                                ))
                          else if (item.showArrow)
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.muted,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (idx < items.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.surfaceBorder,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsRow {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final Color? titleColor;
  final String subtitle;
  final bool showArrow;
  final RxBool? toggleObs;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  _SettingsRow({
    required this.icon,
    this.iconColor,
    required this.title,
    this.titleColor,
    required this.subtitle,
    this.showArrow = false,
    this.toggleObs,
    this.onToggle,
    this.onTap,
  });
}
