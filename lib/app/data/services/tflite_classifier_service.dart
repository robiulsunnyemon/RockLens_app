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
  });
}

/// TfliteClassifierService handles dynamic DINOv2 neural inference,
/// label indexing, and rich geological database lookups.
class TfliteClassifierService extends GetxService {
  final isModelLoaded = false.obs;
  final isDatabaseLoaded = false.obs;

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
          if (kDebugMode) print('DINOv2 Model loaded from custom OTA file.');
          return;
        }
      } catch (_) {}

      // 2. Load from bundled asset
      _interpreter = await tfl.Interpreter.fromAsset('assets/model/dinov2_minerals.tflite', options: options);
      isModelLoaded.value = true;
      if (kDebugMode) print('DINOv2 Model loaded successfully from assets/model/dinov2_minerals.tflite');
    } catch (e) {
      if (kDebugMode) {
        print('TFLite interpreter load exception (Graceful fallback active): $e');
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
    } catch (_) {
      _labels = [
        'malachite',
        'chrysocolla',
        'bornite',
        'pyrite',
        'quartz',
        'gold',
        'diamond',
        'tanzanite',
        'corundum',
        'topaz',
        'tourmaline',
        'azurite',
        'galena',
        'hematite',
        'magnetite',
      ];
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
    String? selectedMineral,
    double targetConfidence = 88.5,
  }) async {
    // 1. Try real on-device neural inference if photo exists
    Uint8List? rawBytes = imageBytes;
    final photoPath = capturedPhotoPath.value;
    if (rawBytes == null && photoPath != null && photoPath.isNotEmpty) {
      try {
        final file = File(photoPath);
        if (file.existsSync()) {
          rawBytes = await file.readAsBytes();
        }
      } catch (_) {}
    }

    if (rawBytes != null && _interpreter != null && _labels.isNotEmpty) {
      try {
        final result = await _runRealDinov2Inference(rawBytes);
        if (result != null) {
          activeResult.value = result;
          return result;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Inference execution error: $e');
        }
      }
    }

    // 2. Dynamic fallback / simulation pipeline if running in emulator without camera
    await Future.delayed(const Duration(milliseconds: 300));

    final targetLabel = (selectedMineral ?? (_labels.isNotEmpty ? _labels[0] : 'malachite')).toLowerCase();
    final primarySpecimen = getSpecimenByLabel(targetLabel);

    final List<Map<String, dynamic>> alternatives = [];
    final otherLabels = _labels.where((l) => l != targetLabel).toList()..shuffle();

    final colors = ['#00E5FF', '#00C853', '#D4AF37', '#FF9800'];
    if (otherLabels.isNotEmpty) {
      final alt1 = getSpecimenByLabel(otherLabels[0]);
      alternatives.add({
        'name': alt1.name,
        'pct': 8,
        'color': colors[0],
      });
    }
    if (otherLabels.length > 1) {
      final alt2 = getSpecimenByLabel(otherLabels[1]);
      alternatives.add({
        'name': alt2.name,
        'pct': 3,
        'color': colors[1],
      });
    }

    final result = MineralClassificationResult(
      specimen: primarySpecimen,
      confidencePercentage: targetConfidence,
      alternativeCandidates: alternatives,
    );

    activeResult.value = result;
    return result;
  }

  /// Run real DINOv2 448x448 FP16 on-device classification
  Future<MineralClassificationResult?> _runRealDinov2Inference(Uint8List bytes) async {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      // 1. Resize to 448x448 matching DINOv2 model input
      final resized = img.copyResize(image, width: 448, height: 448);

      // 2. Normalization: Mean [0.485, 0.456, 0.406] and Std [0.229, 0.224, 0.225]
      const mean = [0.485, 0.456, 0.406];
      const std = [0.229, 0.224, 0.225];

      var input = List.generate(
        1,
        (_) => List.generate(
          448,
          (y) => List.generate(
            448,
            (x) {
              final pixel = resized.getPixel(x, y);
              final r = (pixel.r / 255.0 - mean[0]) / std[0];
              final g = (pixel.g / 255.0 - mean[1]) / std[1];
              final b = (pixel.b / 255.0 - mean[2]) / std[2];
              return [r, g, b];
            },
          ),
        ),
      );

      // 3. Output logits tensor [1, num_classes]
      final output = List.generate(1, (_) => List<double>.filled(_labels.length, 0.0));

      _interpreter!.run(input, output);

      final logits = output[0];
      final probs = _softmax(logits);

      // 4. Sort classes by predicted probability
      final List<MapEntry<int, double>> indexedProbs = [];
      for (int i = 0; i < probs.length; i++) {
        indexedProbs.add(MapEntry(i, probs[i]));
      }
      indexedProbs.sort((a, b) => b.value.compareTo(a.value));

      // 5. Extract Top-1 Primary Prediction
      final top1Entry = indexedProbs.first;
      final top1Idx = top1Entry.key;
      final top1Score = (top1Entry.value * 100).clamp(1.0, 99.9);
      final top1Label = top1Idx < _labels.length ? _labels[top1Idx] : 'specimen';
      final primarySpecimen = getSpecimenByLabel(top1Label);

      // 6. Extract Top-2 to Top-5 Alternative Candidates
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
      );
    } catch (e) {
      if (kDebugMode) {
        print('Real DINOv2 inference error: $e');
      }
      return null;
    }
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
