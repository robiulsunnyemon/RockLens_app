import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../main_nav/controllers/main_nav_controller.dart';

class SyncQueueItem {
  final String id;
  final String name;
  final String loc;
  final String size;
  String status; // 'synced', 'processing', 'pending'
  final String time;

  SyncQueueItem({
    required this.id,
    required this.name,
    required this.loc,
    required this.size,
    required this.status,
    required this.time,
  });
}

class SyncEngineController extends GetxController {
  final isCellularEnabled = false.obs;
  final isSyncing = false.obs;
  final syncedTodayCount = 4.obs;

  final items = <SyncQueueItem>[
    SyncQueueItem(
      id: 'SC-081',
      name: 'Malachite',
      loc: 'Vein #4',
      size: '4.2 MB',
      status: 'synced',
      time: '14:32',
    ),
    SyncQueueItem(
      id: 'SC-080',
      name: 'Chalcopyrite',
      loc: 'Outcrop B',
      size: '3.8 MB',
      status: 'processing',
      time: '12:08',
    ),
    SyncQueueItem(
      id: 'SC-079',
      name: 'Pyrite',
      loc: 'Riverbed',
      size: '5.1 MB',
      status: 'pending',
      time: '09:45',
    ),
    SyncQueueItem(
      id: 'SC-078',
      name: 'Azurite',
      loc: 'Vein #4',
      size: '3.2 MB',
      status: 'pending',
      time: '09:12',
    ),
    SyncQueueItem(
      id: 'SC-077',
      name: 'Hematite',
      loc: 'Cut #2',
      size: '4.6 MB',
      status: 'synced',
      time: 'Aug 17',
    ),
    SyncQueueItem(
      id: 'SC-076',
      name: 'Quartz',
      loc: 'Vein #1',
      size: '2.9 MB',
      status: 'synced',
      time: 'Aug 17',
    ),
  ].obs;

  int get pendingCount => items.where((i) => i.status == 'pending').length;

  void toggleCellular() {
    HapticFeedback.lightImpact();
    isCellularEnabled.value = !isCellularEnabled.value;
  }

  void forceBackgroundSync() {
    if (isSyncing.value) return;

    HapticFeedback.mediumImpact();
    isSyncing.value = true;

    // Simulate batch uploading pending scans
    Timer(const Duration(milliseconds: 1500), () {
      for (final item in items) {
        if (item.status == 'pending') {
          item.status = 'processing';
        }
      }
      items.refresh();
    });

    Timer(const Duration(milliseconds: 3000), () {
      for (final item in items) {
        if (item.status == 'processing') {
          item.status = 'synced';
          syncedTodayCount.value++;
        }
      }
      items.refresh();
      isSyncing.value = false;

      // Update badge count in bottom nav if available
      if (Get.isRegistered<MainNavController>()) {
        Get.find<MainNavController>().stagedCount.value = 0;
      }

      Get.snackbar(
        'Sync Complete',
        'All staged field specimens have been synchronized to cloud vault.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    });
  }
}
