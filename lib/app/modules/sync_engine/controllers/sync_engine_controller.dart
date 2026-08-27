import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/values/app_strings.dart';
import '../../../data/constants/api_endpoints.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/api_client.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/neural_model_sync_service.dart';
import '../../home/controllers/home_controller.dart';
import '../../main_nav/controllers/main_nav_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../vault/controllers/vault_controller.dart';

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

  // Explicit reactive observables so Obx widgets always rebuild when values change
  final pendingCount = 0.obs;
  final queuedSizeFormatted = '0.0 MB'.obs;

  void _recalculateReactiveCounts() {
    final pending = items.where((i) => i.status == 'pending').toList();
    pendingCount.value = pending.length;
    if (pending.isEmpty) {
      queuedSizeFormatted.value = '0.0 MB';
    } else {
      double totalMb = 0.0;
      for (final item in pending) {
        final sizeNum = double.tryParse(item.size.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 3.5;
        totalMb += sizeNum;
      }
      queuedSizeFormatted.value = '${totalMb.toStringAsFixed(1)} MB';
    }
  }

  Timer? _autoSyncHeartbeatTimer;
  bool _isHeartbeatRunning = false;

  @override
  void onInit() {
    super.onInit();
    isCellularEnabled.value = _storage.isCellularSyncEnabled;
    loadSyncQueue();
    _startRealtimeSyncMonitoring();
  }

  @override
  void onClose() {
    _autoSyncHeartbeatTimer?.cancel();
    super.onClose();
  }

  /// Trigger instant live auto-sync immediately (called on saveDiscovery, screen view, or nav)
  Future<void> triggerLiveAutoSync() async {
    loadSyncQueue();
    if (isSyncing.value) return;
    if (pendingCount.value > 0) {
      // Try syncing directly — if it succeeds, backend is reachable; if not, mark offline
      await forceBackgroundSync();
    } else {
      // No pending items — try fetching cloud specimens to verify connectivity
      await _checkConnectivityOnly();
    }
  }

  /// Light connectivity probe (no sync side effects)
  Future<void> _checkConnectivityOnly() async {
    try {
      final res = await _apiClient.get(ApiEndpoints.health);
      isOfflineMode.value = !res.isOk;
    } catch (_) {
      isOfflineMode.value = true;
    }
  }

  /// Real-time sync monitor: attempts sync every 5 seconds if pending items exist
  void _startRealtimeSyncMonitoring() {
    _autoSyncHeartbeatTimer?.cancel();
    // Run initial sync attempt immediately
    triggerLiveAutoSync();

    // Continuously attempt sync every 5 seconds
    _autoSyncHeartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _performHeartbeatSync();
    });
  }

  Future<void> _performHeartbeatSync() async {
    // Guard: prevent concurrent heartbeat calls from stacking up
    if (_isHeartbeatRunning || isSyncing.value) return;
    _isHeartbeatRunning = true;
    try {
      loadSyncQueue();
      if (pendingCount.value > 0) {
        if (kDebugMode) print('[Heartbeat] ${pendingCount.value} pending — attempting auto-sync...');
        await forceBackgroundSync();
      } else {
        await _checkConnectivityOnly();
      }
    } finally {
      _isHeartbeatRunning = false;
    }
  }

  /// Ping FastAPI backend to check real online cloud connectivity
  Future<void> checkBackendConnectivity() async {
    try {
      final res = await _apiClient.get(ApiEndpoints.health);
      if (res.isOk) {
        isOfflineMode.value = false;
      } else {
        _apiClient.baseUrl = ApiEndpoints.fallbackLocalUrl;
        final res2 = await _apiClient.get(ApiEndpoints.health);
        isOfflineMode.value = !res2.isOk;
      }
    } catch (_) {
      isOfflineMode.value = true;
    }
  }


  /// Fetch synchronized cloud specimens from FastAPI backend and merge locally
  Future<void> fetchCloudSpecimens() async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.apiV1}/specimens');
      if (response.isOk && response.body is List) {
        final cloudItems = response.body as List;
        final localLogs = _storage.getDiscoveryLogs();
        final localTags = localLogs.map((l) => l['tag'] as String?).toSet();
        bool hasNew = false;

        for (final item in cloudItems) {
          if (item is Map) {
            final tag = item['tag'] as String?;
            if (tag != null && !localTags.contains(tag)) {
              hasNew = true;
              await _storage.saveDiscoveryLog({
                'tag': tag,
                'name': item['name'] ?? 'Specimen',
                'formula': item['formula'] ?? 'Mineral',
                'conf': (item['confidence'] as num?)?.toInt() ?? 90,
                'grade': item['grade'] ?? 'Specimen',
                'date': 'Cloud Synced',
                'synced': true,
                'loc': item['location_name'] ?? 'Field Concession',
                'notes': item['field_notes'] ?? '',
                'photos': item['photos'] ?? [],
                'hasVoiceNote': item['has_voice_note'] ?? false,
                'voiceDuration': item['voice_duration'],
                'lat': item['latitude'],
                'lon': item['longitude'],
                'altitude': item['altitude'],
                'city': item['city'] ?? 'Field Sector',
                'country': item['country'] ?? 'Mine Concession',
                'timestamp': item['synced_at'] ?? DateTime.now().toIso8601String(),
              });
            }
          }
        }

        if (hasNew) {
          loadSyncQueue();
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().loadRecentScans();
          }
          if (Get.isRegistered<VaultController>()) {
            Get.find<VaultController>().loadCatalogAndDiscoveries();
          }
          if (Get.isRegistered<ProfileController>()) {
            Get.find<ProfileController>().refreshDynamicStats();
          }
        }
      }
    } catch (_) {}
  }

  /// Load real discovery logs from local StorageService
  void loadSyncQueue() {
    final logs = _storage.getDiscoveryLogs();
    final List<SyncQueueItem> queue = [];
    int syncedCount = 0;

    // Check for pending profile credentials update
    if (_storage.isProfilePendingSync) {
      queue.add(
        SyncQueueItem(
          id: '#PROFILE-SYNC',
          name: 'Operator Profile Credentials',
          loc: 'Local Device Cache',
          size: '4.5 KB',
          status: 'pending',
          time: 'Pending Sync',
          rawData: {'type': 'profile'},
        ),
      );
    }

    // Check for pending avatar upload
    if (_storage.isAvatarPendingSync) {
      queue.add(
        SyncQueueItem(
          id: '#AVATAR-SYNC',
          name: 'Operator Profile Avatar',
          loc: 'Local Device Cache',
          size: '1.2 MB',
          status: 'pending',
          time: 'Pending Upload',
          rawData: {'type': 'avatar'},
        ),
      );
    }

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
    _recalculateReactiveCounts();
    _updateNavBadge();
  }

  void toggleCellular() {
    HapticFeedback.lightImpact();
    isCellularEnabled.value = !isCellularEnabled.value;
    _storage.setCellularSyncEnabled(isCellularEnabled.value);
    Get.snackbar(
      AppStrings.snackCellularPolicyTitle,
      AppStrings.snackCellularPolicyMsg(isCellularEnabled.value),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
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
  }

  /// Perform batch upload to FastAPI backend (/api/v1/sync/batch)
  Future<void> forceBackgroundSync({bool forceAll = false}) async {
    if (isSyncing.value) return;

    HapticFeedback.mediumImpact();
    isSyncing.value = true;

    // 1. Sync pending profile credentials if staged
    if (_storage.isProfilePendingSync) {
      final profileItem = items.firstWhereOrNull((i) => i.id == '#PROFILE-SYNC');
      if (profileItem != null) {
        profileItem.status = 'processing';
        items.refresh();
      }

      final cur = _storage.currentUser;
      if (cur != null) {
        try {
          final userRepo = Get.find<UserRepository>();
          final res = await userRepo.updateProfile(
            fullName: cur.fullName,
            designation: cur.designation,
            companyName: cur.companyName,
          );
          if (res.isSuccess) {
            await _storage.setProfilePendingSync(false);
            if (profileItem != null) {
              profileItem.status = 'synced';
              items.refresh();
            }
          } else {
            if (profileItem != null) {
              profileItem.status = 'pending';
              items.refresh();
            }
          }
        } catch (_) {
          if (profileItem != null) {
            profileItem.status = 'pending';
            items.refresh();
          }
        }
      }
    }

    // 2. Sync pending avatar if staged
    if (_storage.isAvatarPendingSync && _storage.pendingAvatarPath != null) {
      final avatarItem = items.firstWhereOrNull((i) => i.id == '#AVATAR-SYNC');
      if (avatarItem != null) {
        avatarItem.status = 'processing';
        items.refresh();
      }

      final avatarPath = _storage.pendingAvatarPath!;
      final avatarFile = File(avatarPath);
      if (await avatarFile.exists()) {
        try {
          final userRepo = Get.find<UserRepository>();
          final bytes = await avatarFile.readAsBytes();
          final filename = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final res = await userRepo.uploadAvatar(fileBytes: bytes, filename: filename);

          if (res.isSuccess && res.data != null) {
            await _storage.clearPendingAvatarSync();
            if (avatarItem != null) {
              avatarItem.status = 'synced';
              items.refresh();
            }
            if (Get.isRegistered<ProfileController>()) {
              Get.find<ProfileController>().userAvatarUrl.value = res.data!.avatarUrl;
            }
            if (Get.isRegistered<HomeController>()) {
              Get.find<HomeController>().refreshUserData();
            }
          } else {
            if (avatarItem != null) {
              avatarItem.status = 'pending';
              items.refresh();
            }
          }
        } catch (e) {
          if (avatarItem != null) {
            avatarItem.status = 'pending';
            items.refresh();
          }
        }
      }
    }

    List<SyncQueueItem> uploadTargets = items
        .where((i) =>
            i.status == 'pending' &&
            i.id != '#AVATAR-SYNC' &&
            i.id != '#PROFILE-SYNC')
        .toList();

    // If no pending items but user clicked sync, sync all specimen items to ensure backend is updated!
    if (uploadTargets.isEmpty &&
        items
            .where((i) =>
                i.id != '#AVATAR-SYNC' && i.id != '#PROFILE-SYNC')
            .isNotEmpty) {
      uploadTargets = items
          .where((i) =>
              i.id != '#AVATAR-SYNC' && i.id != '#PROFILE-SYNC')
          .toList();
    }

    if (uploadTargets.isEmpty) {
      isSyncing.value = false;
      loadSyncQueue();
      return;
    }

    // Set UI state to processing
    for (final item in uploadTargets) {
      item.status = 'processing';
    }
    items.refresh();

    // 2. Upload local specimen photos to Cloudinary CDN before batch syncing
    for (final item in uploadTargets) {
      final raw = item.rawData;
      final rawPhotos = raw['photos'];
      if (rawPhotos is List && rawPhotos.isNotEmpty) {
        final List<String> updatedPhotos = [];
        bool hasCloudinaryUpload = false;

        for (final p in rawPhotos) {
          final photoStr = p.toString();
          if (photoStr.startsWith('http://') || photoStr.startsWith('https://')) {
            updatedPhotos.add(photoStr);
          } else {
            final file = File(photoStr);
            if (file.existsSync()) {
              try {
                final form = FormData({
                  'file': MultipartFile(
                    file.readAsBytesSync(),
                    filename: 'specimen_${item.id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}.jpg',
                    contentType: 'image/jpeg',
                  ),
                  'tag': item.id,
                });

                var uploadRes = await _apiClient.post(
                  '${ApiEndpoints.apiV1}/specimens/upload-photo',
                  form,
                );

                if (!uploadRes.isOk) {
                  _apiClient.baseUrl = ApiEndpoints.fallbackLocalUrl;
                  uploadRes = await _apiClient.post(
                    '${ApiEndpoints.apiV1}/specimens/upload-photo',
                    form,
                  );
                }

                if (uploadRes.isOk && uploadRes.body is Map && uploadRes.body['url'] != null) {
                  final cloudUrl = uploadRes.body['url'].toString();
                  updatedPhotos.add(cloudUrl);
                  hasCloudinaryUpload = true;
                } else {
                  updatedPhotos.add(photoStr);
                }
              } catch (_) {
                updatedPhotos.add(photoStr);
              }
            } else {
              updatedPhotos.add(photoStr);
            }
          }
        }

        if (hasCloudinaryUpload) {
          raw['photos'] = updatedPhotos;
          await _storage.updateDiscoveryLogPhotos(item.id, updatedPhotos);
        }
      }
    }

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
          'city': raw['city'] ?? '',
          'country': raw['country'] ?? '',
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
        _recalculateReactiveCounts();
        isOfflineMode.value = false;

        // Also trigger Neural AI Model OTA background check
        if (Get.isRegistered<NeuralModelSyncService>()) {
          Get.find<NeuralModelSyncService>().checkAndSyncModel();
        }
      } else {
        // Server returned error (e.g. 500 or 400)
        for (final item in uploadTargets) {
          item.status = 'pending';
        }
        isOfflineMode.value = true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sync engine network connection error: $e');
      }
      for (final item in uploadTargets) {
        item.status = 'pending';
      }
      isOfflineMode.value = true;
    } finally {
      loadSyncQueue(); // reads updated storage, calls items.assignAll + _recalculateReactiveCounts
      isSyncing.value = false;
      _updateNavBadge();
    }
  }

  void _updateNavBadge() {
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().stagedCount.value = pendingCount.value;
    }
  }
}
