import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/values/app_strings.dart';
import 'storage_service.dart';

class FaceAuthService extends GetxService {
  final LocalAuthentication _auth = LocalAuthentication();
  final StorageService _storage = Get.find<StorageService>();

  final isHardwareAvailable = false.obs;
  final isFaceEnrolled = false.obs;
  final isFaceAuthEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    isFaceAuthEnabled.value = _storage.isFaceIdEnabled;
    checkHardwareSupport();
  }

  /// Check if device hardware supports biometric / Face ID scanning
  Future<bool> checkHardwareSupport() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      isHardwareAvailable.value = canAuthenticate;

      if (canAuthenticate) {
        final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
        isFaceEnrolled.value = availableBiometrics.isNotEmpty;
      }
      return isHardwareAvailable.value;
    } catch (e) {
      if (kDebugMode) print('Face ID hardware check error: $e');
      isHardwareAvailable.value = false;
      return false;
    }
  }

  /// Trigger on-device Face ID / Biometric scan prompt
  Future<bool> authenticateFace({
    String localizedReason = AppStrings.facePromptLogin,
  }) async {
    try {
      final bool isSupported = await checkHardwareSupport();
      if (!isSupported) {
        Get.snackbar(
          AppStrings.snackBiometricsUnavailableTitle,
          AppStrings.snackBiometricsUnavailableMsg,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        return false;
      }

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      if (kDebugMode) print('Face authentication PlatformException: $e');
      return false;
    } catch (e) {
      if (kDebugMode) print('Face authentication error: $e');
      return false;
    }
  }

  /// Toggle and register Face ID from profile settings
  Future<bool> setFaceIdEnabled(bool enabled) async {
    if (enabled) {
      // Prompt user to verify face before enabling
      final bool success = await authenticateFace(
        localizedReason: AppStrings.facePromptRegister,
      );

      if (success) {
        await _storage.setFaceIdEnabled(true);
        isFaceAuthEnabled.value = true;
        Get.snackbar(
          AppStrings.snackFaceIdActivatedTitle,
          AppStrings.snackFaceIdActivatedMsg,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
        return true;
      } else {
        await _storage.setFaceIdEnabled(false);
        isFaceAuthEnabled.value = false;
        Get.snackbar(
          AppStrings.snackFaceIdCancelledTitle,
          AppStrings.snackFaceIdCancelledMsg,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        return false;
      }
    } else {
      await _storage.setFaceIdEnabled(false);
      isFaceAuthEnabled.value = false;
      Get.snackbar(
        AppStrings.snackFaceIdDisabledTitle,
        AppStrings.snackFaceIdDisabledMsg,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return true;
    }
  }
}
