import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import '../models/mineral_model.dart';

enum ClassificationStatus {
  success,
  lowConfidence,
  modelNotLoaded,
  inferenceFailed,
  noImageProvided,
}

/// Candidate recommendation with percentage confidence and theme accent color
class AlternativeCandidate {
  final String name;
  final int percentage;
  final String color;

  AlternativeCandidate({
    required this.name,
    required this.percentage,
    required this.color,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'pct': percentage,
    'color': color,
  };
}

/// Full Result of a geological classification pass
class MineralClassificationResult {
  final MineralSpecimen specimen;
  final double confidencePercentage;
  final List<Map<String, dynamic>> alternativeCandidates;
  final ClassificationStatus status;
  final String? errorMessage;
  final String? executionMode; // 'DINOv2 On-Device Neural Engine' or 'Error'

  bool get isSuccessful => status == ClassificationStatus.success;
  bool get isLowConfidence => status == ClassificationStatus.lowConfidence;
  bool get hasError => status == ClassificationStatus.modelNotLoaded ||
      status == ClassificationStatus.inferenceFailed ||
      status == ClassificationStatus.noImageProvided;

  String get mineralName => specimen.name;
  String get chemicalFormula => specimen.chemicalFormula;
  String get mineralGroup => specimen.group;
  String get rawOreEstimate => specimen.rawOreEstimate;
  String get specimenEstimate => specimen.specimenEstimate;
  Map<String, String> get properties => specimen.toPropertiesMap();
  List<String> get africanRegions => specimen.africanRegions;
  String get rarityTier => specimen.rarityTier;
  String get economicValue => specimen.economicValue;
  String get toxicity => specimen.toxicity;
  String get description => specimen.description;
  String get identificationTips => specimen.identificationTips;

  const MineralClassificationResult({
    required this.specimen,
    required this.confidencePercentage,
    required this.alternativeCandidates,
    this.status = ClassificationStatus.success,
    this.errorMessage,
    this.executionMode = 'Meta DINOv2 Neural Engine (FP16)',
  });

  factory MineralClassificationResult.error({
    required ClassificationStatus status,
    required String errorMessage,
  }) {
    return MineralClassificationResult(
      specimen: MineralSpecimen.fromFallbackLabel('Unidentified Specimen'),
      confidencePercentage: 0.0,
      alternativeCandidates: const [],
      status: status,
      errorMessage: errorMessage,
      executionMode: 'Execution Error',
    );
  }
}

/// TfliteClassifierService handles dynamic DINOv2 neural inference,
/// label indexing, and rich geological database lookups.
class TfliteClassifierService extends GetxService {
  final isModelLoaded = false.obs;
  final isDatabaseLoaded = false.obs;
  final loadError = ''.obs;

  tfl.Interpreter? _interpreter;
  List<String> _labels = [];
  List<String> get labels => _labels;

  final Map<String, MineralSpecimen> _mineralDatabase = {};
  Map<String, MineralSpecimen> get mineralDatabase => _mineralDatabase;

  // Active classification output accessible across controllers
  final Rx<MineralClassificationResult?> activeResult = Rx<MineralClassificationResult?>(null);
  final RxnString capturedPhotoPath = RxnString();

  @override
  void onInit() {
    super.onInit();
    initService();
  }

  /// Initialize labels, knowledge base, and model
  Future<void> initService() async {
    await loadDatabase();
    await loadLabels();
    await _loadTfliteModel();
  }

  /// Reload model, labels, and database on-the-fly (Hot Update)
  Future<void> reloadModel() async {
    isModelLoaded.value = false;
    isDatabaseLoaded.value = false;
    loadError.value = '';
    await loadDatabase();
    await loadLabels();
    await _loadTfliteModel();
  }

  /// Load DINOv2 TFLite Interpreter with multi-threaded mobile execution
  Future<void> _loadTfliteModel() async {
    try {
      final options = tfl.InterpreterOptions()..threads = 4;

      // 1. Try loading from persistent OTA updated file system first
      try {
        final docsDir = await getApplicationDocumentsDirectory();
        final customModelFile = File('${docsDir.path}/neural_models/dinov2_minerals.tflite');
        if (customModelFile.existsSync()) {
          _interpreter = tfl.Interpreter.fromFile(customModelFile, options: options);
          isModelLoaded.value = true;
          loadError.value = '';
          if (kDebugMode) print('🚀 DINOv2 Model loaded from custom OTA file.');
          return;
        }
      } catch (_) {}

      // 2. Load from bundled asset
      _interpreter = await tfl.Interpreter.fromAsset('assets/model/dinov2_minerals.tflite', options: options);
      isModelLoaded.value = true;
      loadError.value = '';
      if (kDebugMode) {
        final inTensor = _interpreter!.getInputTensor(0);
        final outTensor = _interpreter!.getOutputTensor(0);
        print('🚀 DINOv2 Model loaded! Input Shape: ${inTensor.shape} (Type: ${inTensor.type}), Output Shape: ${outTensor.shape}');
      }
    } catch (e, stack) {
      final err = 'TFLite Model Load Failure: $e';
      loadError.value = err;
      if (kDebugMode) {
        print('⚠️ $err\n$stack');
      }
      isModelLoaded.value = false;
    }
  }

  /// Load rich minerals database from dynamic storage or fallback JSON asset
  Future<void> loadDatabase() async {
    try {
      String jsonString = '';

      // 1. Try loading from persistent OTA updated file system
      try {
        final docsDir = await getApplicationDocumentsDirectory();
        final customDbFile = File('${docsDir.path}/neural_models/minerals_db.json');
        if (customDbFile.existsSync()) {
          jsonString = await customDbFile.readAsString();
        }
      } catch (_) {}

      // 2. Fallback to bundled asset
      if (jsonString.isEmpty) {
        jsonString = await rootBundle.loadString('assets/data/minerals_db.json');
      }

      final Map<String, dynamic> data = json.decode(jsonString);
      final Map<String, dynamic> mineralsMap = data['minerals'] ?? {};

      _mineralDatabase.clear();
      mineralsMap.forEach((key, value) {
        _mineralDatabase[key.toLowerCase()] = MineralSpecimen.fromJson(value);
      });
      isDatabaseLoaded.value = true;
    } catch (_) {
      isDatabaseLoaded.value = true;
    }
  }

  /// Load labels list dynamically from persistent OTA storage or asset
  Future<void> loadLabels() async {
    try {
      String labelsData = '';

      // 1. Try loading from persistent OTA updated file system
      try {
        final docsDir = await getApplicationDocumentsDirectory();
        final customLabelsFile = File('${docsDir.path}/neural_models/labels.txt');
        if (customLabelsFile.existsSync()) {
          labelsData = await customLabelsFile.readAsString();
        }
      } catch (_) {}

      // 2. Fallback to bundled asset
      if (labelsData.isEmpty) {
        labelsData = await rootBundle.loadString('assets/model/labels.txt');
      }

      _labels = labelsData
          .split('\n')
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toList();
      if (kDebugMode) print('📋 Loaded ${_labels.length} mineral labels.');
    } catch (_) {
      _labels = [];
    }
  }

  /// Look up specimen metadata by label with dynamic fallback
  MineralSpecimen getSpecimenByLabel(String label) {
    final cleanKey = label.trim().toLowerCase();
    if (_mineralDatabase.containsKey(cleanKey)) {
      return _mineralDatabase[cleanKey]!;
    }
    return MineralSpecimen.fromFallbackLabel(label);
  }

  /// Classify geological specimen image with real DINOv2 neural inference
  Future<MineralClassificationResult> classifySpecimen({
    Uint8List? imageBytes,
  }) async {
    // 1. Check if model interpreter is initialized
    if (_interpreter == null) {
      await _loadTfliteModel();
      if (_interpreter == null) {
        final errorResult = MineralClassificationResult.error(
          status: ClassificationStatus.modelNotLoaded,
          errorMessage: 'Meta DINOv2 TFLite neural model is not loaded: ${loadError.value.isNotEmpty ? loadError.value : "File assets/model/dinov2_minerals.tflite could not be initialized"}',
        );
        activeResult.value = errorResult;
        return errorResult;
      }
    }

    // 2. Check if image bytes exist
    Uint8List? rawBytes = imageBytes;
    final photoPath = capturedPhotoPath.value;
    if (rawBytes == null && photoPath != null && photoPath.isNotEmpty) {
      try {
        final file = File(photoPath);
        if (file.existsSync()) {
          rawBytes = await file.readAsBytes();
        }
      } catch (e) {
        final errorResult = MineralClassificationResult.error(
          status: ClassificationStatus.inferenceFailed,
          errorMessage: 'Could not read captured photo file: $e',
        );
        activeResult.value = errorResult;
        return errorResult;
      }
    }

    if (rawBytes == null || rawBytes.isEmpty) {
      final errorResult = MineralClassificationResult.error(
        status: ClassificationStatus.noImageProvided,
        errorMessage: 'No image frame was captured by the camera or selected from gallery.',
      );
      activeResult.value = errorResult;
      return errorResult;
    }

    // 3. Execute Real DINOv2 Neural Inference
    try {
      final result = await _runRealDinov2Inference(rawBytes);
      if (result != null) {
        activeResult.value = result;
        return result;
      } else {
        final errorResult = MineralClassificationResult.error(
          status: ClassificationStatus.inferenceFailed,
          errorMessage: 'Image decoding failed or input tensor format was incompatible.',
        );
        activeResult.value = errorResult;
        return errorResult;
      }
    } catch (e, stack) {
      final errorResult = MineralClassificationResult.error(
        status: ClassificationStatus.inferenceFailed,
        errorMessage: 'DINOv2 Neural Inference Execution Failed: $e',
      );
      if (kDebugMode) {
        print('❌ DINOv2 Execution Error: $e\n$stack');
      }
      activeResult.value = errorResult;
      return errorResult;
    }
  }

  /// Run real DINOv2 448x448 FP16 on-device classification using fast typed buffers
  Future<MineralClassificationResult?> _runRealDinov2Inference(Uint8List bytes) async {
    final image = img.decodeImage(bytes);
    if (image == null) {
      if (kDebugMode) print('⚠️ Could not decode image from bytes.');
      return null;
    }

    final inputTensor = _interpreter!.getInputTensor(0);
    final inputShape = inputTensor.shape; // e.g. [1, 3, 448, 448] or [1, 448, 448, 3]
    final isNCHW = inputShape.length == 4 && inputShape[1] == 3;
    final int h = isNCHW ? inputShape[2] : inputShape[1];
    final int w = isNCHW ? inputShape[3] : inputShape[2];

    // 1. High quality resize to model dimensions (e.g. 448x448)
    final resized = img.copyResize(image, width: w, height: h);

    // 2. Normalization: Mean [0.485, 0.456, 0.406] and Std [0.229, 0.224, 0.225]
    const mean = [0.485, 0.456, 0.406];
    const std = [0.229, 0.224, 0.225];

    final inputBuffer = Float32List(1 * 3 * h * w);

    if (isNCHW) {
      // Planar RGB: [1, 3, H, W] (Standard PyTorch DINOv2 layout)
      final int channelSize = h * w;
      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          final pixel = resized.getPixel(x, y);
          final int spatialIdx = y * w + x;
          inputBuffer[0 * channelSize + spatialIdx] = (pixel.r / 255.0 - mean[0]) / std[0];
          inputBuffer[1 * channelSize + spatialIdx] = (pixel.g / 255.0 - mean[1]) / std[1];
          inputBuffer[2 * channelSize + spatialIdx] = (pixel.b / 255.0 - mean[2]) / std[2];
        }
      }
    } else {
      // Interleaved RGB: [1, H, W, 3] (Standard TF layout)
      int pixelIdx = 0;
      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          final pixel = resized.getPixel(x, y);
          inputBuffer[pixelIdx++] = (pixel.r / 255.0 - mean[0]) / std[0];
          inputBuffer[pixelIdx++] = (pixel.g / 255.0 - mean[1]) / std[1];
          inputBuffer[pixelIdx++] = (pixel.b / 255.0 - mean[2]) / std[2];
        }
      }
    }

    // 3. Prepare Typed Multidimensional Views for Interpreter
    final outputTensor = _interpreter!.getOutputTensor(0);
    final outputShape = outputTensor.shape; // e.g. [1, 112]
    final numClasses = outputShape.last;
    final outputBuffer = Float32List(numClasses);

    final input = inputBuffer.reshape(inputShape);
    final output = outputBuffer.reshape(outputShape);

    // 4. Run real TFLite Neural Inference
    _interpreter!.run(input, output);

    final List<double> logits = outputBuffer.toList();
    final probs = _softmax(logits);

    // 5. Sort classes by predicted probability
    final List<MapEntry<int, double>> indexedProbs = [];
    for (int i = 0; i < probs.length; i++) {
      indexedProbs.add(MapEntry(i, probs[i]));
    }
    indexedProbs.sort((a, b) => b.value.compareTo(a.value));

    // 6. Extract Top-1 Primary Prediction
    final top1Entry = indexedProbs.first;
    final top1Idx = top1Entry.key;
    final top1Score = (top1Entry.value * 100).clamp(0.1, 99.9);
    final top1Label = top1Idx < _labels.length ? _labels[top1Idx] : 'specimen';
    final primarySpecimen = getSpecimenByLabel(top1Label);

    // 7. Check if confidence is low (<35%) or Out-Of-Distribution
    final status = (top1Score < 35.0)
        ? ClassificationStatus.lowConfidence
        : ClassificationStatus.success;

    if (kDebugMode) {
      print('🎯 Top-1 Prediction: $top1Label ($top1Score%), Status: $status, Raw Logit: ${logits[top1Idx]}');
    }

    // 8. Extract Top-2 to Top-5 Alternative Candidates
    final colors = ['#00E5FF', '#00C853', '#D4AF37', '#FF9800'];
    final List<Map<String, dynamic>> alternatives = [];
    for (int i = 1; i < math.min(5, indexedProbs.length); i++) {
      final entry = indexedProbs[i];
      final altLabel = entry.key < _labels.length ? _labels[entry.key] : '';
      if (altLabel.isNotEmpty) {
        final altSpecimen = getSpecimenByLabel(altLabel);
        final altPct = (entry.value * 100).round();
        if (altPct > 0) {
          alternatives.add({
            'name': altSpecimen.name,
            'pct': altPct,
            'color': colors[(i - 1) % colors.length],
          });
        }
      }
    }

    return MineralClassificationResult(
      specimen: primarySpecimen,
      confidencePercentage: double.parse(top1Score.toStringAsFixed(1)),
      alternativeCandidates: alternatives,
      status: status,
      executionMode: 'Meta DINOv2 Neural Engine (FP16)',
    );
  }

  /// Softmax activation function to convert logits into probabilities
  List<double> _softmax(List<double> logits) {
    if (logits.isEmpty) return [];
    double maxLogit = logits.reduce(math.max);
    List<double> expScores = logits.map((l) => math.exp((l - maxLogit).clamp(-50.0, 50.0))).toList();
    double sumExp = expScores.reduce((a, b) => a + b);
    if (sumExp == 0) return List<double>.filled(logits.length, 1.0 / logits.length);
    return expScores.map((e) => e / sumExp).toList();
  }

  @override
  void onClose() {
    _interpreter?.close();
    super.onClose();
  }
}
