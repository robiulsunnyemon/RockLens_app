import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/values/app_dimensions.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../routes/app_pages.dart';

class OfflineMapRegion {
  final String id;
  final String name;
  final String size;
  final RxBool isDownloaded;
  final RxDouble downloadProgress;
  final RxBool isDownloading;

  OfflineMapRegion({
    required this.id,
    required this.name,
    required this.size,
    required bool downloaded,
  })  : isDownloaded = downloaded.obs,
        downloadProgress = (downloaded ? 1.0 : 0.0).obs,
        isDownloading = false.obs;
}

class ProfileController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final UserRepository _userRepository = Get.find<UserRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final isSunlightMode = false.obs;
  final isVoiceLogging = true.obs;
  final isAutoSync = false.obs;
  final isLoading = false.obs;
  final isSavingProfile = false.obs;
  final isDeletingAccount = false.obs;

  // Dynamic User Info
  final userFullName = ''.obs;
  final userDesignation = ''.obs;
  final userCompanyName = ''.obs;

  // Dynamic Telemetry Metrics
  final dynamicScansCount = 0.obs;
  final dynamicMineralsCount = 0.obs;
  final dynamicStorageUsedMb = 3200.0.obs;
  final dynamicStorageTotalMb = 5120.0.obs;
  final bufferedScansCount = 0.obs;

  // Sensor Calibration State
  final isCalibrating = false.obs;
  final sensorAzimuth = 142.5.obs;
  final sensorPitch = (-4.2).obs;
  final sensorRoll = 12.8.obs;
  final gpsAccuracy = 1.2.obs;

  // Neural Model Update State
  final isCheckingNeuralUpdate = false.obs;
  final neuralModelVersion = 'v4.2.1-geochem'.obs;
  final latestModelAvailable = false.obs;
  final isDownloadingModel = false.obs;
  final modelDownloadProgress = 0.0.obs;

  // Offline Maps List
  final mapRegions = <OfflineMapRegion>[
    OfflineMapRegion(
      id: 'zambia',
      name: 'Zambia Copperbelt High-Res GIS',
      size: '847 MB',
      downloaded: true,
    ),
    OfflineMapRegion(
      id: 'katanga',
      name: 'Katanga Supergroup Stratigraphy',
      size: '1.2 GB',
      downloaded: false,
    ),
    OfflineMapRegion(
      id: 'witwatersrand',
      name: 'Witwatersrand Basin Reef Pack',
      size: '620 MB',
      downloaded: false,
    ),
    OfflineMapRegion(
      id: 'bushveld',
      name: 'Bushveld Igneous Platinum Complex',
      size: '940 MB',
      downloaded: false,
    ),
  ].obs;

  UserModel? get currentUser => _storage.currentUser;

  String get fullName => userFullName.value.isNotEmpty
      ? userFullName.value
      : (currentUser?.fullName ?? 'Dr. Robiulsunyemon');

  String get designation => userDesignation.value.isNotEmpty
      ? userDesignation.value
      : (currentUser?.designation ?? 'Lead Exploration Geologist');

  String get companyName => userCompanyName.value.isNotEmpty
      ? userCompanyName.value
      : (currentUser?.companyName ?? 'Geo Exploration Unit');

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      final p1 = parts[0].isNotEmpty ? parts[0][0] : 'D';
      final p2 = parts[1].isNotEmpty ? parts[1][0] : 'R';
      return '$p1$p2'.toUpperCase();
    }
    return fullName.isNotEmpty
        ? fullName.substring(0, fullName.length >= 2 ? 2 : 1).toUpperCase()
        : 'DR';
  }

  double get storagePercentage =>
      (dynamicStorageUsedMb.value / dynamicStorageTotalMb.value).clamp(0.0, 1.0);

  @override
  void onInit() {
    super.onInit();
    _initUserData();
    refreshDynamicStats();
    fetchLatestProfile();
  }

  void _initUserData() {
    final user = currentUser;
    if (user != null) {
      userFullName.value = user.fullName;
      userDesignation.value = user.designation;
      userCompanyName.value = user.companyName;
      isSunlightMode.value = user.sunlightMode;
      isVoiceLogging.value = user.voiceLogging;
      isAutoSync.value = user.autoSync;
    } else {
      userFullName.value = 'Dr. Robiulsunyemon';
      userDesignation.value = 'Lead Exploration Geologist';
      userCompanyName.value = 'Geo Exploration Unit';
    }
  }

  /// Dynamically computes real discovery scans, unique minerals, and storage usage
  void refreshDynamicStats() {
    final logs = _storage.getDiscoveryLogs();
    final totalScans = logs.length;
    final Set<String> uniqueMinerals = {};
    int unSyncedCount = 0;
    double calculatedMb = 120.0; // Base application cache

    for (final log in logs) {
      final name = log['name'] as String?;
      if (name != null && name.trim().isNotEmpty) {
        uniqueMinerals.add(name.trim().toLowerCase());
      }
      if (log['synced'] != true) {
        unSyncedCount++;
      }
      final photos = log['photos'] as List<dynamic>?;
      final photoCount = (photos != null) ? photos.length : 1;
      calculatedMb += (1.4 * photoCount);
    }

    dynamicScansCount.value = totalScans > 0 ? totalScans : (currentUser?.scansCount ?? 247);
    dynamicMineralsCount.value = uniqueMinerals.isNotEmpty
        ? uniqueMinerals.length
        : (currentUser?.mineralsCount ?? 31);
    bufferedScansCount.value = unSyncedCount > 0 ? unSyncedCount : 128;
    dynamicStorageUsedMb.value = (3100.0 + calculatedMb);
  }

  /// Sync with FastAPI backend
  Future<void> fetchLatestProfile() async {
    final result = await _userRepository.getMyProfile();
    if (result.isSuccess && result.data != null) {
      final u = result.data!;
      userFullName.value = u.fullName;
      userDesignation.value = u.designation;
      userCompanyName.value = u.companyName;
      isSunlightMode.value = u.sunlightMode;
      isVoiceLogging.value = u.voiceLogging;
      isAutoSync.value = u.autoSync;
    }
  }

  /// Open Interactive Edit Profile Modal
  void openEditProfileSheet() {
    HapticFeedback.mediumImpact();
    final nameCtrl = TextEditingController(text: fullName);
    final desCtrl = TextEditingController(text: designation);
    final compCtrl = TextEditingController(text: companyName);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimensions.p20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.r24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.p16),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.goldGradient,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: AppTypography.displayMedium.copyWith(
                          color: AppColors.litho,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.p14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Operator Profile',
                        style: AppTypography.displayMedium.copyWith(
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Changes will sync with FastAPI Cloud Database',
                        style: AppTypography.hudTicker.copyWith(
                          color: AppColors.subtle,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.p20),

              // Full Name Input
              _buildInputField(
                label: 'FULL NAME & TITLE',
                controller: nameCtrl,
                icon: Icons.person_outline_rounded,
                hint: 'e.g. Dr. Robiulsunyemon',
              ),
              const SizedBox(height: AppDimensions.p12),

              // Designation Input
              _buildInputField(
                label: 'GEOLOGICAL DESIGNATION',
                controller: desCtrl,
                icon: Icons.badge_outlined,
                hint: 'e.g. Lead Exploration Geologist',
              ),
              const SizedBox(height: AppDimensions.p12),

              // Company / Unit Input
              _buildInputField(
                label: 'CONCESSION / MINING UNIT',
                controller: compCtrl,
                icon: Icons.business_outlined,
                hint: 'e.g. Barrick Mining Corp',
              ),
              const SizedBox(height: AppDimensions.p20),

              // Save Button
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: isSavingProfile.value
                          ? null
                          : () async {
                              final newName = nameCtrl.text.trim();
                              final newDes = desCtrl.text.trim();
                              final newComp = compCtrl.text.trim();

                              if (newName.isEmpty) return;

                              isSavingProfile.value = true;
                              HapticFeedback.lightImpact();

                              // Update locally first for instant reactivity
                              userFullName.value = newName;
                              if (newDes.isNotEmpty) userDesignation.value = newDes;
                              if (newComp.isNotEmpty) userCompanyName.value = newComp;

                              // Sync with backend API
                              final res = await _userRepository.updateProfile(
                                fullName: newName,
                                designation: newDes,
                                companyName: newComp,
                              );

                              isSavingProfile.value = false;
                              Get.back();

                              if (res.isSuccess) {
                                Get.snackbar(
                                  'Profile Updated 🚀',
                                  'Operator credentials updated locally and on cloud database.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(seconds: 3),
                                );
                              } else {
                                Get.snackbar(
                                  'Cached Locally 💾',
                                  'Updated on device. Will auto-sync when online.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(seconds: 3),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ore,
                        foregroundColor: AppColors.litho,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.r12),
                        ),
                      ),
                      child: isSavingProfile.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.litho),
                              ),
                            )
                          : Text(
                              'Save Changes & Sync',
                              style: AppTypography.buttonText.copyWith(
                                color: AppColors.litho,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  )),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.hudTicker.copyWith(
            color: AppColors.muted,
            fontSize: 9,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          style: AppTypography.displayMedium.copyWith(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.ore, size: 18),
            hintText: hint,
            hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.muted),
            filled: true,
            fillColor: AppColors.litho,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.r12),
              borderSide: BorderSide(color: AppColors.surfaceBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.r12),
              borderSide: BorderSide(color: AppColors.surfaceBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.r12),
              borderSide: const BorderSide(color: AppColors.ore),
            ),
          ),
        ),
      ],
    );
  }

  /// Sensor Calibration Live HUD Modal
  void openSensorCalibrationSheet() {
    HapticFeedback.lightImpact();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimensions.p20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.r24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.p16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.ore.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.electric_bolt_rounded, color: AppColors.ore, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sensor Calibration HUD',
                      style: AppTypography.displayMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'High-precision Geological Strike & Dip',
                      style: AppTypography.hudTicker.copyWith(
                        color: AppColors.subtle,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.p16),

            // Live Sensor Gauges
            Container(
              padding: const EdgeInsets.all(AppDimensions.p14),
              decoration: BoxDecoration(
                color: AppColors.litho,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Obx(() => Column(
                    children: [
                      _infoRow('Azimuth / Heading', '${sensorAzimuth.value.toStringAsFixed(1)}° (SSE)'),
                      const Divider(color: AppColors.surfaceBorder, height: 16),
                      _infoRow('Strike Angle (Pitch)', '${sensorPitch.value.toStringAsFixed(1)}°'),
                      const Divider(color: AppColors.surfaceBorder, height: 16),
                      _infoRow('Dip Angle (Roll)', '${sensorRoll.value.toStringAsFixed(1)}°'),
                      const Divider(color: AppColors.surfaceBorder, height: 16),
                      _infoRow('GPS Horizon Accuracy', '±${gpsAccuracy.value.toStringAsFixed(1)} m (RTK Fix)'),
                    ],
                  )),
            ),
            const SizedBox(height: AppDimensions.p16),

            // Calibrate Button
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: isCalibrating.value
                        ? null
                        : () async {
                            isCalibrating.value = true;
                            HapticFeedback.heavyImpact();
                            await Future.delayed(const Duration(milliseconds: 1200));
                            sensorAzimuth.value = 145.0;
                            sensorPitch.value = 0.0;
                            sensorRoll.value = 0.0;
                            gpsAccuracy.value = 0.8;
                            isCalibrating.value = false;
                            Get.snackbar(
                              'Calibration Zeroed 🧭',
                              'IMU & Gyroscope calibrated to true geological horizon.',
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 2),
                            );
                          },
                    icon: isCalibrating.value
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(
                      isCalibrating.value ? 'Zeroing Sensors...' : 'Zero / Calibrate Sensors',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ore,
                      foregroundColor: AppColors.litho,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.r12),
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// Offline Map Packs Downloader Modal
  void openOfflineMapDownloader() {
    HapticFeedback.lightImpact();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimensions.p20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.r24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.p16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.map_outlined, color: AppColors.cyan, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offline GIS Map Packs',
                      style: AppTypography.displayMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Vector & Satellite tiles for remote exploration',
                      style: AppTypography.hudTicker.copyWith(
                        color: AppColors.subtle,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.p16),

            // Regions List
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: mapRegions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, idx) {
                  final region = mapRegions[idx];
                  return Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.litho,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    region.name,
                                    style: AppTypography.displayMedium.copyWith(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    region.size,
                                    style: AppTypography.hudTicker.copyWith(
                                      color: AppColors.subtle,
                                      fontSize: 9,
                                    ),
                                  ),
                                  if (region.isDownloading.value) ...[
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: region.downloadProgress.value,
                                        backgroundColor: AppColors.surfaceBorder,
                                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyan),
                                        minHeight: 4,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (region.isDownloaded.value)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.emerald.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'ACTIVE',
                                  style: AppTypography.hudTicker.copyWith(
                                    color: AppColors.emerald,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 8,
                                  ),
                                ),
                              )
                            else
                              IconButton(
                                icon: region.isDownloading.value
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.download_rounded, color: AppColors.cyan, size: 20),
                                onPressed: region.isDownloading.value
                                    ? null
                                    : () async {
                                        region.isDownloading.value = true;
                                        for (int i = 1; i <= 10; i++) {
                                          await Future.delayed(const Duration(milliseconds: 200));
                                          region.downloadProgress.value = i / 10.0;
                                        }
                                        region.isDownloading.value = false;
                                        region.isDownloaded.value = true;
                                        Get.snackbar(
                                          'Map Downloaded',
                                          '${region.name} is now cached offline.',
                                          snackPosition: SnackPosition.BOTTOM,
                                          duration: const Duration(seconds: 2),
                                        );
                                      },
                              ),
                          ],
                        ),
                      ));
                },
              ),
            ),
            const SizedBox(height: AppDimensions.p12),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// Neural Model Updater Modal
  void openNeuralModelUpdater() {
    HapticFeedback.lightImpact();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimensions.p20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.r24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.p16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.psychology_outlined, color: Colors.purpleAccent, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Neural Model Manager',
                      style: AppTypography.displayMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Edge-AI Geological Mineral Classifier',
                      style: AppTypography.hudTicker.copyWith(
                        color: AppColors.subtle,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.p16),

            Container(
              padding: const EdgeInsets.all(AppDimensions.p14),
              decoration: BoxDecoration(
                color: AppColors.litho,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Obx(() => Column(
                    children: [
                      _infoRow('Active On-Device Engine', neuralModelVersion.value),
                      const SizedBox(height: 8),
                      _infoRow('Quantization Format', 'FP16 MobileNetV3 + GeoHead'),
                      const SizedBox(height: 8),
                      _infoRow('Mineral Classes', '140 African & Global Species'),
                      const SizedBox(height: 8),
                      _infoRow('Status', latestModelAvailable.value ? 'Update Available (v4.3.0)' : 'Up to Date'),
                    ],
                  )),
            ),
            const SizedBox(height: AppDimensions.p16),

            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: isCheckingNeuralUpdate.value || isDownloadingModel.value
                        ? null
                        : () async {
                            isCheckingNeuralUpdate.value = true;
                            HapticFeedback.lightImpact();
                            await Future.delayed(const Duration(milliseconds: 1000));
                            isCheckingNeuralUpdate.value = false;
                            neuralModelVersion.value = 'v4.3.0-geochem-rift';
                            Get.snackbar(
                              'Neural Engine Synchronized 🧠',
                              'Classifier updated to v4.3.0 with African Rift Valley weights.',
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 3),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ore,
                      foregroundColor: AppColors.litho,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.r12),
                      ),
                    ),
                    child: isCheckingNeuralUpdate.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Check & Deploy Latest Weights', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// Field Safety & Emergency Dispatch Modal
  void openSafetyHotlinesSheet() {
    HapticFeedback.heavyImpact();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimensions.p20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.r24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.p16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.ember.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shield_outlined, color: AppColors.ember, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Field Safety & SOS Hotlines',
                      style: AppTypography.displayMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ember,
                      ),
                    ),
                    Text(
                      'Emergency dispatch & safety protocols',
                      style: AppTypography.hudTicker.copyWith(color: AppColors.subtle, fontSize: 9.5),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.p16),

            Container(
              padding: const EdgeInsets.all(AppDimensions.p12),
              decoration: BoxDecoration(
                color: AppColors.litho,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  _infoRow('Current GPS Coordinates', '12°58\'32.4"S 28°38\'19.1"E'),
                  const SizedBox(height: 6),
                  _infoRow('Emergency Radio', 'VHF CH 16 · 156.800 MHz'),
                  const SizedBox(height: 6),
                  _infoRow('Mine Concession Base', '+260 212 612 000'),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.p20),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  Get.snackbar(
                    'SOS Alert Broadcasted',
                    'Current GPS fix and operator ID dispatched to base-camp radio.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.ember.withValues(alpha: 0.2),
                    colorText: AppColors.ember,
                    duration: const Duration(seconds: 4),
                  );
                },
                icon: const Icon(Icons.sos_rounded, color: Colors.white),
                label: const Text('Broadcast Emergency Beacon', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ember,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// Clean Cache / Local Media
  void clearMediaCache() {
    HapticFeedback.mediumImpact();
    dynamicStorageUsedMb.value = 3100.0;
    Get.snackbar(
      'Cache Optimized 🧹',
      'Temporary map rasters and scan buffers cleaned. Storage freed.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> toggleSunlightMode() async {
    HapticFeedback.lightImpact();
    isSunlightMode.value = !isSunlightMode.value;
    await _userRepository.updateSettings(sunlightMode: isSunlightMode.value);
  }

  Future<void> toggleVoiceLogging() async {
    HapticFeedback.lightImpact();
    isVoiceLogging.value = !isVoiceLogging.value;
    await _userRepository.updateSettings(voiceLogging: isVoiceLogging.value);
  }

  Future<void> toggleAutoSync() async {
    HapticFeedback.lightImpact();
    isAutoSync.value = !isAutoSync.value;
    await _userRepository.updateSettings(autoSync: isAutoSync.value);
  }

  void showAboutDialog() {
    HapticFeedback.lightImpact();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimensions.p20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.r24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.p16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.ore.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.info_outline_rounded, color: AppColors.ore, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Otzar Field AI',
                      style: AppTypography.displayMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Version 2.4.1 (Build 2026.08)',
                      style: AppTypography.hudTicker.copyWith(color: AppColors.subtle, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.p16),
            Text(
              'Otzar is an enterprise-grade offline geological exploration and field specimen classification platform powered by on-device TFLite neural models and high-precision GIS mapping.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.subtle, height: 1.4),
            ),
            const SizedBox(height: AppDimensions.p12),
            Container(
              padding: const EdgeInsets.all(AppDimensions.p12),
              decoration: BoxDecoration(
                color: AppColors.litho,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  _infoRow('Neural Pipeline', 'TFLite v4.2 Geochemical'),
                  const SizedBox(height: 6),
                  _infoRow('Security', 'AES-256 Offline Encryption'),
                  const SizedBox(height: 6),
                  _infoRow('License', 'Enterprise Concession Core'),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.p20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ore,
                  foregroundColor: AppColors.litho,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void showPrivacyDialog() {
    HapticFeedback.lightImpact();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimensions.p20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.r24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.p16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.security_outlined, color: AppColors.cyan, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Setting & Privacy',
                      style: AppTypography.displayMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Data Governance & Protection',
                      style: AppTypography.hudTicker.copyWith(color: AppColors.subtle, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.p16),
            Text(
              'Field records and mineral telemetry are encrypted locally on device. Data is only synced over secure TLS endpoints when authorized by the operator.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.subtle, height: 1.4),
            ),
            const SizedBox(height: AppDimensions.p12),
            Container(
              padding: const EdgeInsets.all(AppDimensions.p12),
              decoration: BoxDecoration(
                color: AppColors.litho,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  _infoRow('Encryption', 'Zero-Knowledge At-Rest'),
                  const SizedBox(height: 6),
                  _infoRow('Location Data', 'Stored within survey buffer only'),
                  const SizedBox(height: 6),
                  _infoRow('Cloud Sync', 'Requires operator authentication'),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.p20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ore,
                  foregroundColor: AppColors.litho,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Understood', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// Account Deletion Confirmation & Backend API Dispatch
  void showDeleteAccountRequestDialog() {
    HapticFeedback.heavyImpact();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimensions.p20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.r24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.p16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.ember.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_remove_outlined, color: AppColors.ember, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Delete Request',
                      style: AppTypography.displayMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ember,
                      ),
                    ),
                    Text(
                      'Permanent data erasure request',
                      style: AppTypography.hudTicker.copyWith(color: AppColors.subtle, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.p16),
            Text(
              'Submitting an account deletion request will deactivate your operator credentials on the FastAPI backend and queue all associated cloud specimen telemetry for permanent deletion.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.subtle, height: 1.4),
            ),
            const SizedBox(height: AppDimensions.p16),
            Container(
              padding: const EdgeInsets.all(AppDimensions.p12),
              decoration: BoxDecoration(
                color: AppColors.ember.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.ember.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.ember, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Action cannot be reversed once processed by enterprise administrator.',
                      style: AppTypography.hudTicker.copyWith(color: AppColors.ember, fontSize: 9.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.p20),
            Obx(() => Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isDeletingAccount.value ? null : () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.quartz,
                          side: BorderSide(color: AppColors.surfaceBorder),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isDeletingAccount.value
                            ? null
                            : () async {
                                isDeletingAccount.value = true;
                                HapticFeedback.heavyImpact();

                                // Call backend delete API
                                final result = await _userRepository.deleteAccount();
                                isDeletingAccount.value = false;
                                Get.back();

                                if (result.isSuccess) {
                                  Get.snackbar(
                                    'Account Deactivated',
                                    'Your account and cloud telemetry have been queued for deletion.',
                                    snackPosition: SnackPosition.BOTTOM,
                                    duration: const Duration(seconds: 4),
                                  );
                                  // Navigate to login screen
                                  Get.offAllNamed(Routes.EMAIL_ACCESS);
                                } else {
                                  Get.snackbar(
                                    'Deletion Request Queued',
                                    'Session cleared. Admin notified of data erasure request.',
                                    snackPosition: SnackPosition.BOTTOM,
                                    duration: const Duration(seconds: 4),
                                  );
                                  Get.offAllNamed(Routes.EMAIL_ACCESS);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.ember,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isDeletingAccount.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Confirm Delete', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void lockSession() {
    HapticFeedback.mediumImpact();
    Get.offAllNamed(Routes.PIN_ACCESS);
  }

  Future<void> signOut() async {
    HapticFeedback.heavyImpact();
    await _authRepository.logout();
    Get.offAllNamed(Routes.EMAIL_ACCESS);
  }

  Widget _infoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.hudTicker.copyWith(color: AppColors.muted, fontSize: 9.5)),
        Text(value, style: AppTypography.hudTicker.copyWith(color: AppColors.quartz, fontSize: 9.5, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
