import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../data/services/tflite_classifier_service.dart';
import '../../result/controllers/result_controller.dart';

class MohsReference {
  final double value;
  final String label;
  const MohsReference({required this.value, required this.label});
}

class StreakColorItem {
  final String name;
  final int colorHex;
  final int borderHex;
  const StreakColorItem({required this.name, required this.colorHex, required this.borderHex});
}

class FieldTestController extends GetxController {
  final TfliteClassifierService _classifier = Get.find<TfliteClassifierService>();

  final mohs = 3.5.obs;
  final streak = 'Pale Green'.obs;
  final magnetism = 'Non-Magnetic'.obs;
  final acidReaction = 'Effervescent'.obs;
  final targetMineralName = 'Malachite'.obs;
  final baseConfidence = 86.0.obs;

  static const List<MohsReference> mohsReferences = [
    MohsReference(value: 1.0, label: 'Talc (1.0)'),
    MohsReference(value: 2.5, label: 'Fingernail (2.5)'),
    MohsReference(value: 3.5, label: 'Copper Penny (3.5)'),
    MohsReference(value: 4.0, label: 'Iron Nail (4.0)'),
    MohsReference(value: 5.5, label: 'Knife Blade (5.5)'),
    MohsReference(value: 7.0, label: 'Quartz Crystal (7.0)'),
    MohsReference(value: 10.0, label: 'Diamond (10.0)'),
  ];

  static const List<StreakColorItem> streakColors = [
    StreakColorItem(name: 'White', colorHex: 0xFFF8FAFC, borderHex: 0xFFE2E8F0),
    StreakColorItem(name: 'Pale Green', colorHex: 0xFF86EFAC, borderHex: 0xFF4ADE80),
    StreakColorItem(name: 'Black', colorHex: 0xFF1A1A1A, borderHex: 0xFF374151),
    StreakColorItem(name: 'Red-Brown', colorHex: 0xFF92400E, borderHex: 0xFFB45309),
    StreakColorItem(name: 'Yellow', colorHex: 0xFFFBBF24, borderHex: 0xFFF59E0B),
    StreakColorItem(name: 'Blue-Grey', colorHex: 0xFF64748B, borderHex: 0xFF475569),
  ];

  @override
  void onInit() {
    super.onInit();
    _initTargetSpecimen();
  }

  void _initTargetSpecimen() {
    final active = _classifier.activeResult.value;
    if (active != null) {
      targetMineralName.value = active.mineralName;
      baseConfidence.value = active.confidencePercentage;

      // Extract approximate Mohs hardness from specimen metadata
      final hardnessStr = active.properties['MOHS HARDNESS'] ?? '3.5';
      final match = RegExp(r'(\d+(\.\d+)?)').firstMatch(hardnessStr);
      if (match != null) {
        mohs.value = double.tryParse(match.group(1)!) ?? 3.5;
      }

      final streakStr = active.properties['STREAK'] ?? '';
      if (streakStr.toLowerCase().contains('green')) {
        streak.value = 'Pale Green';
      } else if (streakStr.toLowerCase().contains('black') || streakStr.toLowerCase().contains('dark')) {
        streak.value = 'Black';
      } else if (streakStr.toLowerCase().contains('red') || streakStr.toLowerCase().contains('brown')) {
        streak.value = 'Red-Brown';
      } else if (streakStr.toLowerCase().contains('yellow')) {
        streak.value = 'Yellow';
      } else if (streakStr.toLowerCase().contains('blue')) {
        streak.value = 'Blue-Grey';
      } else {
        streak.value = 'White';
      }
    }
  }

  double get calculatedConfidence {
    double boost = 0.0;
    final active = _classifier.activeResult.value;

    if (active != null) {
      final specimenStreak = (active.properties['STREAK'] ?? '').toLowerCase();
      if (specimenStreak.contains(streak.value.toLowerCase())) {
        boost += 5.5;
      }

      final hardnessStr = active.properties['MOHS HARDNESS'] ?? '';
      final match = RegExp(r'(\d+(\.\d+)?)').firstMatch(hardnessStr);
      if (match != null) {
        final targetMohs = double.tryParse(match.group(1)!) ?? 3.5;
        if ((mohs.value - targetMohs).abs() <= 1.0) {
          boost += 4.5;
        }
      }

      if (active.mineralGroup.toLowerCase().contains('carbonate') && acidReaction.value == 'Effervescent') {
        boost += 3.0;
      }
    } else {
      if (streak.value == 'Pale Green') boost += 5.0;
      if (mohs.value >= 3.0 && mohs.value <= 4.5) boost += 3.0;
      if (acidReaction.value == 'Effervescent') boost += 2.0;
    }

    return (baseConfidence.value + boost).clamp(0.0, 99.4);
  }

  bool get isAdjusted => calculatedConfidence > baseConfidence.value;

  MohsReference get nearestReference {
    return mohsReferences.reduce(
      (a, b) => (b.value - mohs.value).abs() < (a.value - mohs.value).abs() ? b : a,
    );
  }

  void setMohs(double value) {
    HapticFeedback.selectionClick();
    mohs.value = value;
  }

  void setStreak(String name) {
    HapticFeedback.selectionClick();
    streak.value = name;
  }

  void setMagnetism(String value) {
    HapticFeedback.selectionClick();
    magnetism.value = value;
  }

  void setAcidReaction(String value) {
    HapticFeedback.selectionClick();
    acidReaction.value = value;
  }

  void updateAndReturn() {
    HapticFeedback.mediumImpact();
    if (Get.isRegistered<ResultController>()) {
      Get.find<ResultController>().updateConfidenceFromFieldTest(calculatedConfidence);
    }
    Get.back();
  }
}
