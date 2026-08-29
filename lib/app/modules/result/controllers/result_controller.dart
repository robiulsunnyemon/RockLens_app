import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../data/services/tflite_classifier_service.dart';
import '../../../routes/app_pages.dart';

class ResultController extends GetxController {
  final TfliteClassifierService _classifier = Get.find<TfliteClassifierService>();

  final mineralName = ''.obs;
  final chemicalFormula = ''.obs;
  final mineralGroup = ''.obs;
  final confidencePercentage = 0.0.obs;
  final rawOreEstimate = ''.obs;
  final specimenEstimate = ''.obs;
  final properties = <String, String>{}.obs;
  final alternativeCandidates = <Map<String, dynamic>>[].obs;
  final africanRegions = <String>[].obs;
  final rarityTier = 'Common'.obs;
  final economicValue = 'Standard'.obs;
  final description = ''.obs;
  final isLowConfidence = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final executionMode = ''.obs;

  RxnString get capturedPhotoPath => _classifier.capturedPhotoPath;

  @override
  void onInit() {
    super.onInit();
    _loadResult();
  }

  Future<void> _loadResult() async {
    MineralClassificationResult? active = _classifier.activeResult.value;
    active ??= await _classifier.classifySpecimen();

    hasError.value = active.hasError;
    errorMessage.value = active.errorMessage ?? '';
    isLowConfidence.value = active.isLowConfidence;
    executionMode.value = active.executionMode ?? 'Meta DINOv2 Neural Engine';

    mineralName.value = active.mineralName;
    chemicalFormula.value = active.chemicalFormula;
    mineralGroup.value = active.mineralGroup;
    confidencePercentage.value = active.confidencePercentage;
    rawOreEstimate.value = active.rawOreEstimate;
    specimenEstimate.value = active.specimenEstimate;
    properties.assignAll(active.properties);
    alternativeCandidates.assignAll(active.alternativeCandidates);
    africanRegions.assignAll(active.africanRegions);
    rarityTier.value = active.rarityTier;
    economicValue.value = active.economicValue;
    description.value = active.description;
  }

  void updateConfidenceFromFieldTest(double newConfidence) {
    confidencePercentage.value = newConfidence;
  }

  void goToFieldTest() {
    HapticFeedback.lightImpact();
    Get.toNamed(Routes.FIELD_TEST);
  }

  void confirmAndLog() {
    HapticFeedback.mediumImpact();
    Get.toNamed(Routes.LOGGING);
  }

  void discardAndScanAgain() {
    HapticFeedback.lightImpact();
    Get.offNamed(Routes.SCANNER);
  }
}
