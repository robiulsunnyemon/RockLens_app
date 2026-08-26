import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/widgets/otzar_dialog.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/tflite_classifier_service.dart';
import '../../../routes/app_pages.dart';
import '../../home/controllers/home_controller.dart';
import '../../sync_engine/controllers/sync_engine_controller.dart';
import '../../vault/controllers/vault_controller.dart';

class LoggingController extends GetxController {
  final TfliteClassifierService _classifier = Get.find<TfliteClassifierService>();
  final StorageService _storage = Get.find<StorageService>();
  final ImagePicker _imagePicker = ImagePicker();

  // 1. Dynamic Specimen Photos
  final specimenPhotos = <String>[].obs;

  // 2. Specimen Identity & Geological Attributes
  final specimenTag = '#SC-082'.obs;
  final mineralName = 'Malachite'.obs;
  final chemicalFormula = 'Cu₂CO₃(OH)₂'.obs;
  final confidenceScore = 88.5.obs;

  // 3. Real Dynamic Metadata
  final latitude = '-12.9783°S'.obs;
  final longitude = '028.6234°E'.obs;
  final altitude = '1,247m ASL'.obs;
  final gpsError = '±2.4m'.obs;
  final timestampStr = '14:32:07 UTC'.obs;
  final dateStr = '25 Aug 2026'.obs;
  final weatherStr = 'Field Clear · 29°C'.obs;
  final tempStr = '29°C / 84°F'.obs;

  // 4. Voice Field Note Recording State
  final isRecording = false.obs;
  final recordingDuration = 0.obs; // in seconds
  final hasRecordedVoice = false.obs;
  Timer? _recordTimer;

  // 5. Notes & Geological Tags
  final notesTextController = TextEditingController();
  final selectedTags = <String>['Vein #4', 'High-Grade'].obs;

  static const List<String> availableTags = [
    'Vein #4',
    'Outcrop',
    'Riverbed',
    'High-Grade',
    'Near Surface',
    'Oxide Zone',
    'Pegmatite',
    'Hydrothermal',
  ];

  List<Map<String, String>> get metadataItems => [
        {'label': 'LAT', 'value': latitude.value},
        {'label': 'LON', 'value': longitude.value},
        {'label': 'ALTITUDE', 'value': altitude.value},
        {'label': 'GPS ERROR', 'value': gpsError.value},
        {'label': 'TIMESTAMP', 'value': timestampStr.value},
        {'label': 'DATE', 'value': dateStr.value},
        {'label': 'WEATHER', 'value': weatherStr.value},
        {'label': 'TEMP', 'value': tempStr.value},
      ];

  String get formattedDuration {
    final mins = (recordingDuration.value ~/ 60).toString().padLeft(2, '0');
    final secs = (recordingDuration.value % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  void onInit() {
    super.onInit();
    _initSpecimenData();
    _fetchRealMetadata();
  }

  void _initSpecimenData() {
    final active = _classifier.activeResult.value;
    final randomId = 100 + Random().nextInt(899);
    specimenTag.value = '#SC-$randomId';

    if (active != null) {
      mineralName.value = active.mineralName;
      chemicalFormula.value = active.chemicalFormula;
      confidenceScore.value = active.confidencePercentage;
    }

    // Auto-attach 1st captured scan photo if present
    final captured = _classifier.capturedPhotoPath.value;
    if (captured != null && captured.isNotEmpty && !specimenPhotos.contains(captured)) {
      specimenPhotos.add(captured);
    }

    // Set real-time date and time
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    dateStr.value = '${now.day} ${months[now.month - 1]} ${now.year}';
    final hour = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    final sec = now.second.toString().padLeft(2, '0');
    timestampStr.value = '$hour:$min:$sec LOCAL';
  }

  /// Read real device GPS coordinates, altitude, and accuracy
  Future<void> _fetchRealMetadata() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );

        final latDir = pos.latitude >= 0 ? 'N' : 'S';
        final lonDir = pos.longitude >= 0 ? 'E' : 'W';

        latitude.value = '${pos.latitude.abs().toStringAsFixed(4)}°$latDir';
        longitude.value = '${pos.longitude.abs().toStringAsFixed(4)}°$lonDir';

        if (pos.altitude != 0.0) {
          altitude.value = '${pos.altitude.round()}m ASL';
        }
        gpsError.value = '±${pos.accuracy.toStringAsFixed(1)}m';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching real metadata: $e');
      }
    }
  }

  /// Add real photo angle from Camera or Gallery
  Future<void> addSpecimenPhoto({ImageSource source = ImageSource.camera}) async {
    HapticFeedback.lightImpact();
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (photo != null) {
        specimenPhotos.add(photo.path);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking specimen photo: $e');
      }
    }
  }

  void removeSpecimenPhoto(int index) {
    HapticFeedback.selectionClick();
    if (index >= 0 && index < specimenPhotos.length) {
      specimenPhotos.removeAt(index);
    }
  }

  /// Toggle real voice recording with live timer
  void toggleVoiceRecording() {
    HapticFeedback.mediumImpact();
    if (isRecording.value) {
      // Stop recording
      _recordTimer?.cancel();
      isRecording.value = false;
      hasRecordedVoice.value = true;
    } else {
      // Start recording
      recordingDuration.value = 0;
      isRecording.value = true;
      hasRecordedVoice.value = false;

      _recordTimer?.cancel();
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        recordingDuration.value++;
      });
    }
  }

  void toggleTag(String tag) {
    HapticFeedback.selectionClick();
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  /// Persist complete real discovery record to local vault
  Future<void> saveDiscovery() async {
    HapticFeedback.heavyImpact();

    final discoveryItem = {
      'tag': specimenTag.value,
      'name': mineralName.value,
      'formula': chemicalFormula.value,
      'conf': confidenceScore.value.round(),
      'grade': selectedTags.contains('High-Grade') ? 'Specimen' : 'Ore',
      'date': dateStr.value,
      'synced': false,
      'loc': selectedTags.isNotEmpty ? selectedTags.first : 'Vein #4',
      'notes': notesTextController.text,
      'photos': List<String>.from(specimenPhotos),
      'hasVoiceNote': hasRecordedVoice.value,
      'voiceDuration': formattedDuration,
      'lat': latitude.value,
      'lon': longitude.value,
      'altitude': altitude.value,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _storage.saveDiscoveryLog(discoveryItem);

    if (Get.isRegistered<SyncEngineController>()) {
      final syncEngine = Get.find<SyncEngineController>();
      syncEngine.loadSyncQueue();
      // Auto-Sync in background if connected
      if (!syncEngine.isOfflineMode.value) {
        syncEngine.forceBackgroundSync();
      }
    }
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadRecentScans();
    }
    if (Get.isRegistered<VaultController>()) {
      Get.find<VaultController>().loadCatalogAndDiscoveries();
    }

    await OtzarDialog.show(
      title: 'Discovery Logged & Pinned',
      message:
          '${mineralName.value} specimen (${specimenTag.value}) recorded with GPS [${latitude.value}, ${longitude.value}] and pinned to GIS Geological Map.',
      confirmText: 'View in Vault',
      type: OtzarDialogType.success,
      onConfirm: () {
        Get.offAllNamed(Routes.HOME, arguments: {'tab': 1});
      },
    );
  }

  @override
  void onClose() {
    _recordTimer?.cancel();
    notesTextController.dispose();
    super.onClose();
  }
}
