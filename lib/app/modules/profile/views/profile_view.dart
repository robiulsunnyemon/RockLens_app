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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(
            left: AppDimensions.p16,
            right: AppDimensions.p16,
            top: AppDimensions.p12,
            bottom: AppDimensions.p32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(AppDimensions.p16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF181C24), Color(0xFF1E2330)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppDimensions.radius24,
                  border: Border.all(
                    color: AppColors.ore.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Initials Avatar
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.goldGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.ore.withValues(alpha: 0.25),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: Center(
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
                        const SizedBox(width: AppDimensions.p16),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.fullName,
                                style: AppTypography.displayMedium.copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                controller.designation,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.subtle,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                controller.companyName,
                                style: AppTypography.monoTag.copyWith(
                                  color: AppColors.ore,
                                  fontSize: 9.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.p16),

                    // Metrics 3 Boxes (SCANS, MINERALS, TEAM)
                    Row(
                      children: [
                        _buildMetricBox(
                          label: 'SCANS',
                          value: '${controller.scansCount}',
                        ),
                        const SizedBox(width: AppDimensions.p8),
                        _buildMetricBox(
                          label: 'MINERALS',
                          value: '${controller.mineralsCount}',
                        ),
                        const SizedBox(width: AppDimensions.p8),
                        _buildMetricBox(
                          label: 'TEAM',
                          value: '${controller.teamCount}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.p16),

              // Local Storage Gauge Card
              Container(
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
                        Text(
                          '3.2 GB / 5.0 GB',
                          style: AppTypography.hudTicker.copyWith(
                            color: AppColors.subtle,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.p8),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.rFull),
                      child: Container(
                        height: 8,
                        color: const Color(0xFF252B3A),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: controller.storagePercentage,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: AppColors.goldGradient,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p6),

                    // Gauge Subtext
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '62% used',
                          style: AppTypography.hudTicker.copyWith(
                            color: AppColors.muted,
                            fontSize: 8.5,
                          ),
                        ),
                        Text(
                          '128 SCANS BUFFERED',
                          style: AppTypography.hudTicker.copyWith(
                            color: AppColors.emerald,
                            fontSize: 8.5,
                          ),
                        ),
                      ],
                    ),
                  ],
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
                    subtitle: 'GPS, camera, accelerometer',
                    showArrow: true,
                  ),
                  _SettingsRow(
                    icon: Icons.map_outlined,
                    title: 'Offline Map Downloads',
                    subtitle: 'Zambia Copperbelt · 847 MB',
                    showArrow: true,
                  ),
                  _SettingsRow(
                    icon: Icons.psychology_outlined,
                    title: 'Neural Model Update',
                    subtitle: 'v4.2.1 · Current',
                    showArrow: true,
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
                    icon: Icons.groups_outlined,
                    title: 'Team Sync',
                    subtitle: 'West Africa Survey Unit · 8 members',
                    showArrow: true,
                  ),
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
                  ),
                  _SettingsRow(
                    icon: Icons.shield_outlined,
                    title: 'Field Safety & Hotlines',
                    subtitle: 'Emergency dispatch & safety guidelines',
                    showArrow: true,
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
                          Icon(item.icon, color: AppColors.ore, size: 20),
                          const SizedBox(width: AppDimensions.p12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: AppTypography.displayMedium.copyWith(
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
  final String title;
  final String subtitle;
  final bool showArrow;
  final RxBool? toggleObs;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showArrow = false,
    this.toggleObs,
    this.onToggle,
    this.onTap,
  });
}
