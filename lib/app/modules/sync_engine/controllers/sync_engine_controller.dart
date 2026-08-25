import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../data/constants/api_endpoints.dart';
import '../../../data/services/api_client.dart';
import '../../../data/services/storage_service.dart';
import '../../main_nav/controllers/main_nav_controller.dart';

class SyncQueueItem {
  final String id;
  final String name;
  final String loc;
  final String size;
  String status; // 'synced', 'processing', 'pending'
  final String time;
  final Map<String, dynamic> rawData;

  SyncQueueItem({
    required this.id,
    required this.name,
    required this.loc,
    required this.size,
    required this.status,
    required this.time,
    required this.rawData,
  });
}

class SyncEngineController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final ApiClient _apiClient = Get.find<ApiClient>();

  final isCellularEnabled = false.obs;
  final isSyncing = false.obs;
  final isOfflineMode = true.obs;
  final syncedTodayCount = 0.obs;

  final items = <SyncQueueItem>[].obs;

  int get pendingCount => items.where((i) => i.status == 'pending').length;

  String get queuedSizeFormatted {
    final pendingItems = items.where((i) => i.status == 'pending');
    if (pendingItems.isEmpty) return '0.0 MB';
    double totalMb = 0.0;
    for (final item in pendingItems) {
      final sizeNum = double.tryParse(item.size.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 3.5;
      totalMb += sizeNum;
    }
    return '${totalMb.toStringAsFixed(1)} MB';
  }

  @override
  void onInit() {
    super.onInit();
    loadSyncQueue();
    checkBackendConnectivity();
  }

  /// Ping FastAPI backend to check real online cloud connectivity
  Future<void> checkBackendConnectivity() async {
    try {
      final res = await _apiClient.get(ApiEndpoints.health);
      if (res.isOk) {
        isOfflineMode.value = false;
      } else {
        // Try fallback localhost if primary Wi-Fi IP is unreachable
        _apiClient.baseUrl = ApiEndpoints.fallbackLocalUrl;
        final res2 = await _apiClient.get(ApiEndpoints.health);
        if (res2.isOk) {
          isOfflineMode.value = false;
        } else {
          isOfflineMode.value = true;
        }
      }
    } catch (_) {
      isOfflineMode.value = true;
    }
  }

  /// Load real discovery logs from local StorageService
  void loadSyncQueue() {
    final logs = _storage.getDiscoveryLogs();
    final List<SyncQueueItem> queue = [];
    int syncedCount = 0;

    if (logs.isNotEmpty) {
      for (int i = 0; i < logs.length; i++) {
        final log = logs[i];
        final isSynced = log['synced'] == true;
        if (isSynced) syncedCount++;

        final tag = log['tag'] as String? ?? '#SC-${100 + i}';
        final name = log['name'] as String? ?? 'Specimen';
        final loc = log['loc'] as String? ?? 'Field Deposit';
        final date = log['date'] as String? ?? 'Today';
        final photos = log['photos'] as List<dynamic>?;
        final photoCount = (photos != null) ? photos.length : 1;
        final mbSize = (2.2 + photoCount * 1.4).toStringAsFixed(1);

        queue.add(SyncQueueItem(
          id: tag,
          name: name,
          loc: loc,
          size: '$mbSize MB',
          status: isSynced ? 'synced' : 'pending',
          time: date,
          rawData: log,
        ));
      }
    }

    syncedTodayCount.value = syncedCount;
    items.assignAll(queue);
    _updateNavBadge();
  }

  void toggleCellular() {
    HapticFeedback.lightImpact();
    isCellularEnabled.value = !isCellularEnabled.value;
  }

  /// Reset all stored logs to pending so user can force push them to backend
  void forceResetAllToPending() {
    HapticFeedback.selectionClick();
    for (final item in items) {
      item.status = 'pending';
      item.rawData['synced'] = false;
    }
    items.refresh();
    _updateNavBadge();
    Get.snackbar(
      'Queue Ready',
      'All ${items.length} records staged for cloud synchronization.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Perform batch upload to FastAPI backend (/api/v1/sync/batch)
  Future<void> forceBackgroundSync({bool forceAll = false}) async {
    if (isSyncing.value) return;

    List<SyncQueueItem> uploadTargets = items.where((i) => i.status == 'pending').toList();

    // If no pending items but user clicked sync, sync all items to ensure backend is updated!
    if (uploadTargets.isEmpty && items.isNotEmpty) {
      uploadTargets = List.from(items);
    }

    if (uploadTargets.isEmpty) {
      Get.snackbar(
        'Queue Clean',
        'No specimen records found to synchronize.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    isSyncing.value = true;

    // Set UI state to processing
    for (final item in uploadTargets) {
      item.status = 'processing';
    }
    items.refresh();

    final syncPayload = {
      'device_id': 'RMX3933-ANDROID',
      'operator_email': _storage.currentUser?.email ?? 'operator@otzar.io',
      'items': uploadTargets.map((p) {
        final raw = p.rawData;
        return {
          'tag': p.id,
          'name': p.name,
          'formula': raw['formula'] ?? '',
          'conf': (raw['conf'] as num?)?.toDouble() ?? 90.0,
          'grade': raw['grade'] ?? 'Specimen',
          'loc': p.loc,
          'notes': raw['notes'] ?? '',
          'photos': raw['photos'] ?? [],
          'hasVoiceNote': raw['hasVoiceNote'] ?? false,
          'voiceDuration': raw['voiceDuration'] ?? '00:00',
          'lat': raw['lat'] ?? '',
          'lon': raw['lon'] ?? '',
          'altitude': raw['altitude'] ?? '',
          'timestamp': raw['timestamp'] ?? DateTime.now().toIso8601String(),
        };
      }).toList(),
    };

    try {
      // First attempt with active baseUrl (Wi-Fi IP)
      var response = await _apiClient.post(
        ApiEndpoints.syncBatch,
        syncPayload,
      );

      // If failed, try fallback localhost with adb reverse
      if (!response.isOk) {
        _apiClient.baseUrl = ApiEndpoints.fallbackLocalUrl;
        response = await _apiClient.post(
          ApiEndpoints.syncBatch,
          syncPayload,
        );
      }

      if (response.isOk) {
        // Backend successfully received and persisted batch in SQL database
        final List<String> syncedTags = uploadTargets.map((p) => p.id).toList();
        await _storage.markLogsAsSynced(syncedTags);

        for (final item in uploadTargets) {
          item.status = 'synced';
          item.rawData['synced'] = true;
        }
        syncedTodayCount.value = items.where((i) => i.status == 'synced').length;
        isOfflineMode.value = false;

        Get.snackbar(
          'Cloud Sync Succeeded! 🚀',
          '${uploadTargets.length} specimen records successfully written to FastAPI Cloud Database.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      } else {
        // Server returned error (e.g. 500 or 400)
        final errorMsg = _apiClient.parseErrorMessage(response);
        for (final item in uploadTargets) {
          item.status = 'pending';
        }
        isOfflineMode.value = true;

        Get.snackbar(
          'Sync Failed',
          'Backend returned error: $errorMsg',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sync engine network connection error: $e');
      }
      for (final item in uploadTargets) {
        item.status = 'pending';
      }
      isOfflineMode.value = true;

      Get.snackbar(
        'Server Unreachable',
        'Cannot connect to backend at ${ApiEndpoints.baseUrl}. Ensure server is running.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } finally {
      items.refresh();
      isSyncing.value = false;
      _updateNavBadge();
    }
  }

  void _updateNavBadge() {
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().stagedCount.value = pendingCount;
    }
  }
}
