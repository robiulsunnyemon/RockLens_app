import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../gis_map/controllers/gis_map_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../sync_engine/controllers/sync_engine_controller.dart';
import '../../vault/controllers/vault_controller.dart';

class MainNavController extends GetxController {
  final currentIndex = 0.obs;
  final stagedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _handleArguments();
  }

  void _handleArguments() {
    if (Get.arguments is Map && Get.arguments['tab'] != null) {
      final tab = Get.arguments['tab'];
      if (tab is int && tab >= 0 && tab <= 4) {
        currentIndex.value = tab;
      }
    }
  }

  void changePage(int index) {
    if (currentIndex.value != index) {
      HapticFeedback.selectionClick();
      currentIndex.value = index;

      // When switching back to Home (tab 0), immediately refresh user info and scans
      if (index == 0 && Get.isRegistered<HomeController>()) {
        final home = Get.find<HomeController>();
        home.refreshUserData();
        home.loadRecentScans();
      }

      // When switching to Discoveries/Vault (tab 1), refresh real scanned specimens
      if (index == 1 && Get.isRegistered<VaultController>()) {
        Get.find<VaultController>().loadCatalogAndDiscoveries();
      }

      // When switching to GIS Map (tab 2), refresh dynamic pins
      if (index == 2 && Get.isRegistered<GisMapController>()) {
        Get.find<GisMapController>().loadAllMapPins();
      }

      // When switching to Sync Engine (tab 3), refresh sync queue and auto-sync if pending
      if (index == 3 && Get.isRegistered<SyncEngineController>()) {
        final sync = Get.find<SyncEngineController>();
        sync.loadSyncQueue();
        if (!sync.isOfflineMode.value && sync.pendingCount > 0) {
          sync.forceBackgroundSync();
        }
      }

      // When switching to Profile (tab 4), refresh real storage & profile stats
      if (index == 4 && Get.isRegistered<ProfileController>()) {
        final profile = Get.find<ProfileController>();
        profile.refreshDynamicStats();
        profile.fetchLatestProfile();
      }
    }
  }

  void navigateToTab(int index) {
    changePage(index);
  }
}
