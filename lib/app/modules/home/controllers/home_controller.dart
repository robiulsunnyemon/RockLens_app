import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/storage_service.dart';
import '../../../routes/app_pages.dart';
import '../../main_nav/controllers/main_nav_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../sync_engine/controllers/sync_engine_controller.dart';

class HomeController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  UserModel? get currentUser => _storage.currentUser;

  // Reactive user profile observables
  final userFullName = ''.obs;
  final userDesignation = ''.obs;
  final userCompanyName = ''.obs;
  final userAvatarPath = RxnString();
  final userAvatarUrl = RxnString();

  String get operatorName => userFullName.value.isNotEmpty
      ? userFullName.value
      : (currentUser?.fullName ?? 'Operator');

  String get initials {
    final name = operatorName.trim();
    final parts = name.split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase() : 'OP';
  }

  String get designation => userDesignation.value.isNotEmpty
      ? userDesignation.value
      : (currentUser?.designation ?? 'Lead Exploration Geologist');

  String get companyName => userCompanyName.value.isNotEmpty
      ? userCompanyName.value
      : (currentUser?.companyName ?? 'Pan-African Mineral Consortium');

  // Dynamic Telemetry Metrics
  final todayFindsCount = 0.obs;
  final estimatedValue = 0.0.obs;
  final pendingSyncCount = 0.obs;

  // Reactive observable list for recent scans (100% real logs only)
  final recentScans = <Map<String, dynamic>>[].obs;

  String get estValueFormatted {
    if (estimatedValue.value <= 0) return r'$0';
    if (estimatedValue.value >= 1000) {
      return '\$${(estimatedValue.value / 1000).toStringAsFixed(1)}K';
    }
    return '\$${estimatedValue.value.toInt()}';
  }

  @override
  void onInit() {
    super.onInit();
    refreshUserData();
    loadRecentScans();
  }

  /// Pull-to-refresh handler for Home Screen
  Future<void> onRefresh() async {
    HapticFeedback.mediumImpact();
    refreshUserData();
    loadRecentScans();

    if (Get.isRegistered<SyncEngineController>()) {
      await Get.find<SyncEngineController>().triggerLiveAutoSync();
    }
    if (Get.isRegistered<ProfileController>()) {
      await Get.find<ProfileController>().fetchLatestProfile();
    }

    // Smooth UI animation delay
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void refreshUserData() {
    final u = _storage.currentUser;
    if (u != null) {
      userFullName.value = u.fullName;
      userDesignation.value = u.designation;
      userCompanyName.value = u.companyName;
      userAvatarUrl.value = u.avatarUrl;
    }
    userAvatarPath.value = _storage.localAvatarPath;
  }

  void loadRecentScans() {
    final logs = _storage.getDiscoveryLogs();

    if (logs.isNotEmpty) {
      int unSynced = 0;
      double totalVal = 0;

      final items = logs.map((log) {
        if (log['synced'] != true) {
          unSynced++;
        }
        totalVal += 600.0;

        final photos = log['photos'] as List<dynamic>?;
        final photoPath = (photos != null && photos.isNotEmpty) ? photos.first.toString() : null;

        return {
          'name': log['name'] ?? 'Specimen',
          'formula': log['formula'] ?? 'Mineral',
          'conf': log['conf'] ?? 92,
          'grade': log['grade'] ?? 'Specimen',
          'time': log['date'] ?? 'Recent',
          'color': _getMineralColorHex(log['name'] as String? ?? ''),
          'photo': photoPath,
          'rawLog': log,
        };
      }).toList();

      todayFindsCount.value = logs.length;
      estimatedValue.value = totalVal;
      if (_storage.isAvatarPendingSync) unSynced++;
      if (_storage.isProfilePendingSync) unSynced++;
      pendingSyncCount.value = unSynced;
      recentScans.assignAll(items);
    } else {
      // 0 Scans logged: Strictly zero metrics & empty list
      todayFindsCount.value = 0;
      estimatedValue.value = 0.0;
      int extraPending = (_storage.isAvatarPendingSync ? 1 : 0) + (_storage.isProfilePendingSync ? 1 : 0);
      pendingSyncCount.value = extraPending;
      recentScans.clear();
    }
  }

  int _getMineralColorHex(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('malachite')) return 0xFF00C853;
    if (lower.contains('tanzanite') || lower.contains('azurite')) return 0xFF6366F1;
    if (lower.contains('gold') || lower.contains('pyrite') || lower.contains('coltan')) return 0xFFD4AF37;
    if (lower.contains('bornite') || lower.contains('copper')) return 0xFFFF9100;
    if (lower.contains('chrysocolla') || lower.contains('tourmaline') || lower.contains('quartz')) return 0xFF00E5FF;
    if (lower.contains('biotite') || lower.contains('emerald')) return 0xFF10B981;
    return 0xFF00E5FF;
  }

  void startScanning() {
    Get.toNamed(Routes.SCANNER);
  }

  void goToExportHub() {
    Get.toNamed(Routes.EXPORT_HUB);
  }

  void goToSync() {
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().changePage(3);
    }
  }

  void goToVault() {
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().changePage(1);
    }
  }

  void goToMap() {
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().changePage(2);
    }
  }

  void goToProfile() {
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().changePage(4);
    }
  }
}
