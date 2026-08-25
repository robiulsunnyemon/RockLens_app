import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../routes/app_pages.dart';

class ProfileController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final UserRepository _userRepository = Get.find<UserRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final isSunlightMode = false.obs;
  final isVoiceLogging = true.obs;
  final isAutoSync = false.obs;
  final isLoading = false.obs;

  UserModel? get currentUser => _storage.currentUser;

  String get fullName => currentUser?.fullName ?? 'Dr. K. Osei';
  String get designation => currentUser?.designation ?? 'Lead Exploration Geologist';
  String get companyName => currentUser?.companyName ?? 'Barrick Mining Corp';
  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName.substring(0, 2).toUpperCase() : 'KO';
  }

  int get scansCount => currentUser?.scansCount ?? 247;
  int get mineralsCount => currentUser?.mineralsCount ?? 31;
  int get teamCount => currentUser?.teamCount ?? 8;

  double get storageUsedMb => currentUser?.storageUsedMb ?? 3200.0;
  double get storageTotalMb => currentUser?.storageTotalMb ?? 5120.0;
  double get storagePercentage => (storageUsedMb / storageTotalMb).clamp(0.0, 1.0);

  @override
  void onInit() {
    super.onInit();
    final user = currentUser;
    if (user != null) {
      isSunlightMode.value = user.sunlightMode;
      isVoiceLogging.value = user.voiceLogging;
      isAutoSync.value = user.autoSync;
    }
    fetchLatestProfile();
  }

  Future<void> fetchLatestProfile() async {
    final result = await _userRepository.getMyProfile();
    if (result.isSuccess && result.data != null) {
      final u = result.data!;
      isSunlightMode.value = u.sunlightMode;
      isVoiceLogging.value = u.voiceLogging;
      isAutoSync.value = u.autoSync;
    }
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

  void lockSession() {
    HapticFeedback.mediumImpact();
    Get.offAllNamed(Routes.PIN_ACCESS);
  }

  Future<void> signOut() async {
    HapticFeedback.heavyImpact();
    await _authRepository.logout();
    Get.offAllNamed(Routes.EMAIL_ACCESS);
  }
}
