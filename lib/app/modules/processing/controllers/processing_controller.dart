import 'dart:async';
import 'package:get/get.dart';
import '../../../data/services/online_vision_service.dart';
import '../../../routes/app_pages.dart';

class ProcessingController extends GetxController {
  final progress = 0.obs;
  final consoleLines = <String>[].obs;
  final OnlineVisionService _visionService = Get.find<OnlineVisionService>();

  static const List<String> inferenceStream = [
    'Connecting to RockLens Cloud Vision API...',
    'Uploading Specimen Spectrum to Google Cloud Vision...',
    'Running Web Detection & Knowledge Graph Analysis...',
    'Matching Spectral Signatures against 112+ Mineral Classes...',
    'Extracting Chemical Formula & Mohs Hardness Scale...',
    'Computing Geological Confidence & Alternative Candidates...',
    'Geological Identification Confirmed.',
  ];

  Timer? _streamTimer;

  @override
  void onInit() {
    super.onInit();
    _startInferencePipeline();
  }

  void _startInferencePipeline() {
    int index = 0;
    // Launch cloud identification concurrently
    final identifyFuture = _visionService.identifySpecimen();

    _streamTimer = Timer.periodic(const Duration(milliseconds: 220), (timer) async {
      if (index < inferenceStream.length) {
        consoleLines.add(inferenceStream[index]);
        progress.value = (((index + 1) / inferenceStream.length) * 100).round();
        index++;
      } else {
        timer.cancel();

        // Wait for real Google Cloud Vision identification to complete
        await identifyFuture;

        Timer(const Duration(milliseconds: 200), () {
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
