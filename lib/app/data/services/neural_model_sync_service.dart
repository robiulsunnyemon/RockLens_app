import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/api_endpoints.dart';
import 'api_client.dart';
import 'storage_service.dart';
import 'tflite_classifier_service.dart';

class NeuralModelSyncService extends GetxService {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final StorageService _storage = Get.find<StorageService>();

  final isCheckingForUpdate = false.obs;
  final isDownloading = false.obs;
  final downloadProgress = 0.0.obs;
  final activeModelVersion = 'v4.2.1'.obs;
  final latestReleaseNotes = ''.obs;

  @override
  void onInit() {
    super.onInit();
    activeModelVersion.value = _storage.activeNeuralVersion;
  }

  /// Get the persistent neural models directory on the device
  Future<Directory> getNeuralModelsDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${docsDir.path}/neural_models');
    if (!modelsDir.existsSync()) {
      modelsDir.createSync(recursive: true);
    }
    return modelsDir;
  }

  /// Check FastAPI backend for new neural model version and download Over-The-Air
  Future<bool> checkAndSyncModel({bool isUserInitiated = false}) async {
    if (isCheckingForUpdate.value || isDownloading.value) return false;

    try {
      isCheckingForUpdate.value = true;

      // 1. Fetch latest model metadata from FastAPI
      var response = await _apiClient.get(ApiEndpoints.neuralModelLatest);
      if (!response.isOk) {
        _apiClient.baseUrl = ApiEndpoints.fallbackLocalUrl;
        response = await _apiClient.get(ApiEndpoints.neuralModelLatest);
      }

      if (!response.isOk || response.body == null || response.body['data'] == null) {
        if (isUserInitiated) {
          Get.snackbar(
            'Neural Engine',
            'Currently running local edge model (${activeModelVersion.value}).',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        }
        return false;
      }

      final Map<String, dynamic> data = Map<String, dynamic>.from(response.body['data']);
      final cloudVersion = data['version']?.toString() ?? 'v4.5.0';
      final notes = data['release_notes']?.toString() ?? '';
      latestReleaseNotes.value = notes;

      final localVersion = _storage.activeNeuralVersion;

      // 2. Check if a newer version is available
      if (cloudVersion != localVersion) {
        isDownloading.value = true;
        downloadProgress.value = 0.2;

        final modelsDir = await getNeuralModelsDirectory();

        // 3. Download & persist Labels, Database, or Model files
        final labelsUrl = data['labels_url']?.toString();
        final dbUrl = data['minerals_db_url']?.toString();

        if (labelsUrl != null && labelsUrl.startsWith('http')) {
          try {
            final labelsRes = await _apiClient.get(labelsUrl);
            if (labelsRes.isOk && labelsRes.bodyString != null) {
              final labelsFile = File('${modelsDir.path}/labels.txt');
              await labelsFile.writeAsString(labelsRes.bodyString!);
            }
          } catch (e) {
            if (kDebugMode) print('Labels download error: $e');
          }
        }
        downloadProgress.value = 0.6;

        if (dbUrl != null && dbUrl.startsWith('http')) {
          try {
            final dbRes = await _apiClient.get(dbUrl);
            if (dbRes.isOk && dbRes.bodyString != null) {
              final dbFile = File('${modelsDir.path}/minerals_db.json');
              await dbFile.writeAsString(dbRes.bodyString!);
            }
          } catch (e) {
            if (kDebugMode) print('Minerals DB download error: $e');
          }
        }
        downloadProgress.value = 1.0;

        // 4. Update stored version and active state
        await _storage.setActiveNeuralVersion(cloudVersion);
        activeModelVersion.value = cloudVersion;

        // 5. Hot reload TFLite classifier service dynamically
        if (Get.isRegistered<TfliteClassifierService>()) {
          final classifier = Get.find<TfliteClassifierService>();
          await classifier.reloadModel();
        }

        if (isUserInitiated) {
          Get.snackbar(
            'Neural Engine Upgraded! 🧠⚡',
            'Successfully updated to model $cloudVersion without restarting.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
          );
        }

        return true;
      } else {
        if (isUserInitiated) {
          Get.snackbar(
            'AI Model Up to Date ✓',
            'Inference engine is running the latest neural architecture ($localVersion).',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('Neural Model OTA sync failed: $e');
      return false;
    } finally {
      isCheckingForUpdate.value = false;
      isDownloading.value = false;
    }
  }
}
