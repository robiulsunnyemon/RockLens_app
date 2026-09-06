import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/online_vision_service.dart';
import '../../../routes/app_pages.dart';

enum ScanMode { single, burst }

class ScaleReferenceItem {
  final String name;
  final String dimension;

  const ScaleReferenceItem({required this.name, required this.dimension});
}

class ScannerController extends GetxController {
  final scanMode = ScanMode.single.obs;
  final isTorchOn = false.obs;
  final isScanning = false.obs;
  final isCameraInitialized = false.obs;
  final cameraError = ''.obs;

  // Real Camera controllers & state
  CameraController? cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIdx = 0;
  final ImagePicker _picker = ImagePicker();

  // Dynamic Live telemetry data from GPS and Compass sensors
  final elevation = '1,247m'.obs;
  final bearing = 'N 042°'.obs;
  final latitude = '-12.9783°S'.obs;
  final longitude = '028.6234°E'.obs;

  // Sensor subscription handles
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<CompassEvent>? _compassSubscription;

  // Reticle Detection State
  String get detectionStatusText {
    if (isScanning.value) {
      return 'ANALYZING SURFACE & SPECTRAL REFLECTANCE...';
    }
    return 'TARGET ACQUIRED · TAP SHUTTER';
  }

  // Dynamic Scale Reference Selector
  final scaleItems = const [
    ScaleReferenceItem(name: '25mm coin', dimension: '25mm'),
    ScaleReferenceItem(name: '10mm grid', dimension: '10mm'),
    ScaleReferenceItem(name: 'Field Pen', dimension: '140mm'),
    ScaleReferenceItem(name: 'Rock Hammer', dimension: '300mm'),
    ScaleReferenceItem(name: 'Fingernail', dimension: '15mm'),
  ];
  final selectedScaleIdx = 0.obs;
  ScaleReferenceItem get currentScale => scaleItems[selectedScaleIdx.value];

  @override
  void onInit() {
    super.onInit();
    initCamera();
    initSensors();
  }

  /// Initialize hardware GPS and Compass sensors
  Future<void> initSensors() async {
    _startCompassStream();
    _startLocationService();
  }

  /// Read real device compass heading stream
  void _startCompassStream() {
    try {
      _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
        final double? heading = event.heading;
        if (heading != null) {
          bearing.value = _formatBearing(heading);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Compass stream error: $e');
      }
    }
  }

  String _formatBearing(double heading) {
    // Normalize to 0 - 360
    final double normalized = (heading % 360 + 360) % 360;
    final int degrees = normalized.round();
    final String degStr = degrees.toString().padLeft(3, '0');

    String dir = 'N';
    if (degrees >= 23 && degrees < 68) {
      dir = 'NE';
    } else if (degrees >= 68 && degrees < 113) {
      dir = 'E';
    } else if (degrees >= 113 && degrees < 158) {
      dir = 'SE';
    } else if (degrees >= 158 && degrees < 203) {
      dir = 'S';
    } else if (degrees >= 203 && degrees < 248) {
      dir = 'SW';
    } else if (degrees >= 248 && degrees < 293) {
      dir = 'W';
    } else if (degrees >= 293 && degrees < 338) {
      dir = 'NW';
    }

    return '$dir $degStr°';
  }

  /// Read real device GPS coordinates & Altitude
  Future<void> _startLocationService() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final Position currentPos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
          ),
        );
        _updatePositionUI(currentPos);

        _positionSubscription = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            distanceFilter: 5,
          ),
        ).listen(_updatePositionUI);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Location sensor error: $e');
      }
    }
  }

  void _updatePositionUI(Position pos) {
    final latDir = pos.latitude >= 0 ? 'N' : 'S';
    final lonDir = pos.longitude >= 0 ? 'E' : 'W';

    latitude.value = '${pos.latitude.abs().toStringAsFixed(4)}°$latDir';
    longitude.value = '${pos.longitude.abs().toStringAsFixed(4)}°$lonDir';

    if (pos.altitude != 0.0) {
      elevation.value = '${pos.altitude.round()}m';
    }
  }

  /// Cycle scale reference upon user tap
  void cycleScaleReference() {
    HapticFeedback.selectionClick();
    selectedScaleIdx.value = (selectedScaleIdx.value + 1) % scaleItems.length;
  }

  /// Initialize hardware camera with fallback for simulators/desktop
  Future<void> initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        // Default to first back camera if available
        final backIdx = _cameras.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
        );
        _selectedCameraIdx = backIdx != -1 ? backIdx : 0;
        await _setupCameraController(_cameras[_selectedCameraIdx]);
      } else {
        cameraError.value = 'No physical camera detected. Simulated HUD active.';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Camera init error: $e');
      }
      cameraError.value = 'Camera initialization fallback active.';
    }
  }

  Future<void> _setupCameraController(CameraDescription camera) async {
    // Notify UI to cleanly detach previous preview
    isCameraInitialized.value = false;
    isTorchOn.value = false;

    final prevController = cameraController;
    cameraController = null;
    if (prevController != null) {
      await prevController.dispose();
    }

    final newController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await newController.initialize();
      cameraController = newController;
      isCameraInitialized.value = true;
    } catch (e) {
      if (kDebugMode) {
        print('Camera controller setup error: $e');
      }
      isCameraInitialized.value = false;
    }
  }

  void setMode(ScanMode mode) {
    HapticFeedback.selectionClick();
    scanMode.value = mode;
  }

  Future<void> toggleTorch() async {
    HapticFeedback.lightImpact();

    if (cameraController != null && isCameraInitialized.value) {
      try {
        final newTorchState = !isTorchOn.value;
        await cameraController!.setFlashMode(
          newTorchState ? FlashMode.torch : FlashMode.off,
        );
        isTorchOn.value = newTorchState;
      } catch (e) {
        if (kDebugMode) {
          print('Torch toggle error: $e');
        }
      }
    }
  }

  /// Toggle smartly between Back and Front lenses
  Future<void> switchCamera() async {
    if (_cameras.length <= 1) return;
    HapticFeedback.selectionClick();

    final currentLens = cameraController?.description.lensDirection;
    int targetIdx = -1;

    // Search for opposite lens direction (e.g. Back -> Front or Front -> Back)
    for (int i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection != currentLens) {
        targetIdx = i;
        break;
      }
    }

    if (targetIdx == -1) {
      targetIdx = (_selectedCameraIdx + 1) % _cameras.length;
    }

    _selectedCameraIdx = targetIdx;
    await _setupCameraController(_cameras[_selectedCameraIdx]);
  }

  /// Pick specimen photo from Gallery
  Future<void> pickFromGallery() async {
    HapticFeedback.lightImpact();
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image != null) {
        await analyzePickedPhoto(image.path);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Gallery pick error: $e');
      }
    }
  }

  /// Analyze a selected gallery photo without triggering camera capture
  Future<void> analyzePickedPhoto(String path) async {
    if (isScanning.value) return;
    HapticFeedback.mediumImpact();

    if (Get.isRegistered<OnlineVisionService>()) {
      Get.find<OnlineVisionService>().capturedPhotoPath.value = path;
    }

    // Immediately navigate to Processing Screen so the live camera viewfinder does not flash
    Get.toNamed(Routes.PROCESSING);
  }

  /// Capture image from live camera feed and run analysis
  Future<void> captureAndAnalyze() async {
    if (isScanning.value) return;

    HapticFeedback.heavyImpact();
    isScanning.value = true;

    if (cameraController != null && isCameraInitialized.value) {
      try {
        final XFile picture = await cameraController!.takePicture();
        if (Get.isRegistered<OnlineVisionService>()) {
          Get.find<OnlineVisionService>().capturedPhotoPath.value = picture.path;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Capture error: $e');
        }
      }
    }

    // Laser scan animation duration then navigate to Processing Screen
    Timer(const Duration(milliseconds: 1200), () {
      isScanning.value = false;
      Get.toNamed(Routes.PROCESSING);
    });
  }

  void goBack() {
    Get.back();
  }

  @override
  void onClose() {
    _positionSubscription?.cancel();
    _compassSubscription?.cancel();
    cameraController?.dispose();
    super.onClose();
  }
}
