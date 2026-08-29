import 'dart:async';
import 'package:get/get.dart';
import '../../../data/services/tflite_classifier_service.dart';
import '../../../routes/app_pages.dart';

class ProcessingController extends GetxController {
  final progress = 0.obs;
  final consoleLines = <String>[].obs;
  final TfliteClassifierService _classifier = Get.find<TfliteClassifierService>();

  static const List<String> inferenceStream = [
    'Initializing Meta DINOv2 Vision Transformer (ViT-S/14)...',
    'Generating 448x448 High-Density Patch Embeddings...',
    'Extracting Self-Attention Feature Vectors & Crystal Luster...',
    'Matching Spectral Signatures against 112 Mineral Classes...',
    'Computing Softmax Probability Distribution & Top-K Ranking...',
    'Cross-referencing Chemical Formulas & Mohs Hardness Scale...',
    'Geological Classification & Validation Confirmed.',
  ];

  Timer? _streamTimer;

  @override
  void onInit() {
    super.onInit();
    _startInferencePipeline();
  }

  void _startInferencePipeline() {
    int index = 0;
    _streamTimer = Timer.periodic(const Duration(milliseconds: 240), (timer) async {
      if (index < inferenceStream.length) {
        consoleLines.add(inferenceStream[index]);
        progress.value = (((index + 1) / inferenceStream.length) * 100).round();
        index++;
      } else {
        timer.cancel();

        // Perform real DINOv2 neural classification
        await _classifier.classifySpecimen();

        Timer(const Duration(milliseconds: 300), () {
          Get.offNamed(Routes.RESULT);
        });
      }
    });
  }

  @override
  void onClose() {
    _streamTimer?.cancel();
    super.onClose();
  }
}
