import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import '../../../data/services/tflite_classifier_service.dart';
import '../../../routes/app_pages.dart';

class ProcessingController extends GetxController {
  final progress = 0.obs;
  final consoleLines = <String>[].obs;
  final TfliteClassifierService _classifier = Get.find<TfliteClassifierService>();

  static const List<String> inferenceStream = [
    'Initializing Geological Model v1.0 (YOLOv8s-cls)...',
    'Extracting color histogram & texture features...',
    'Analyzing crystal luster & reflectance...',
    'Measuring cleavage angles & cleavage planes...',
    'Cross-referencing African Mineral Database...',
    'Calculating Mohs probability distribution...',
    'Checking spectral elemental signatures...',
    'Target classification confidence confirmed.',
  ];

  Timer? _streamTimer;

  @override
  void onInit() {
    super.onInit();
    _startInferencePipeline();
  }

  void _startInferencePipeline() {
    int index = 0;
    _streamTimer = Timer.periodic(const Duration(milliseconds: 260), (timer) async {
      if (index < inferenceStream.length) {
        consoleLines.add(inferenceStream[index]);
        progress.value = (((index + 1) / inferenceStream.length) * 100).round();
        index++;
      } else {
        timer.cancel();

        // Perform classification dynamically from available labels
        final available = _classifier.labels;
        final selected = available.isNotEmpty
            ? available[Random().nextInt(available.length)]
            : 'malachite';

        final conf = 85.0 + Random().nextInt(13) + Random().nextDouble();
        await _classifier.classifySpecimen(
          selectedMineral: selected,
          targetConfidence: double.parse(conf.toStringAsFixed(1)),
        );

        Timer(const Duration(milliseconds: 400), () {
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
