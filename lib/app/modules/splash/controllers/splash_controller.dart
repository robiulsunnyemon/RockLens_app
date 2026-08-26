import 'dart:async';
import 'package:get/get.dart';
import '../../../core/values/app_strings.dart';
import '../../../data/services/storage_service.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final currentStepIndex = 0.obs;
  final progress = 0.0.obs;

  Timer? _stepTimer;
  Timer? _navTimer;

  String get currentStepText {
    if (currentStepIndex.value < AppStrings.splashSteps.length) {
      return AppStrings.splashSteps[currentStepIndex.value];
    }
    return AppStrings.splashSteps.last;
  }

  @override
  void onInit() {
    super.onInit();
    _startInitialization();
  }

  void _startInitialization() {
    _stepTimer = Timer.periodic(const Duration(milliseconds: 550), (timer) {
      if (currentStepIndex.value < AppStrings.splashSteps.length - 1) {
        currentStepIndex.value++;
      }
      if (progress.value < 1.0) {
        progress.value = (progress.value + 0.22).clamp(0.0, 1.0);
      }
    });

    _navTimer = Timer(const Duration(milliseconds: 3200), () {
      // Auto-Login: Check if valid access token & user profile exist in storage
      if (_storage.isAuthenticated) {
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.offNamed(Routes.ONBOARDING);
      }
    });
  }

  @override
  void onClose() {
    _stepTimer?.cancel();
    _navTimer?.cancel();
    super.onClose();
  }
}
