import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/values/app_strings.dart';
import '../../../core/widgets/offline_mode_sheet.dart';
import '../../../core/widgets/otzar_dialog.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/face_auth_service.dart';
import '../../../routes/app_pages.dart';

class EmailAccessController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final StorageService _storage = Get.find<StorageService>();

  final emailTextController = TextEditingController();
  final emailError = RxnString();
  final isLoading = false.obs;
  final isFaceAuthenticating = false.obs;

  bool get canUseFaceId => _storage.isFaceIdEnabled && _storage.savedBiometricToken != null;

  final emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  @override
  void onInit() {
    super.onInit();
    final lastEmail = _storage.lastEmail;
    if (lastEmail != null && lastEmail.isNotEmpty) {
      emailTextController.text = lastEmail;
    }
  }

  /// 1-Tap Face ID Biometric Login
  Future<void> loginWithFaceId() async {
    if (!canUseFaceId) return;

    try {
      HapticFeedback.lightImpact();
      final faceService = Get.isRegistered<FaceAuthService>()
          ? Get.find<FaceAuthService>()
          : Get.put(FaceAuthService());

      final bool isFaceMatched = await faceService.authenticateFace(
        localizedReason: 'Scan face to unlock Otzar Geological Vault instantly',
      );

      if (!isFaceMatched) return;

      isFaceAuthenticating.value = true;
      final biometricToken = _storage.savedBiometricToken!;

      final result = await _authRepository.verifyBiometricToken(biometricToken);
      isFaceAuthenticating.value = false;

      if (result.isSuccess && result.data != null) {
        final userName = result.data!.user.fullName;
        Get.snackbar(
          AppStrings.snackFaceIdAuthSuccessTitle,
          AppStrings.snackFaceIdAuthSuccessMsg(userName),
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        Get.offAllNamed(Routes.MAIN_NAV);
      } else {
        // If offline but face matched and local session exists, allow offline access
        if (_storage.currentUser != null) {
          final userName = _storage.currentUser!.fullName;
          Get.snackbar(
            AppStrings.snackOfflineFaceUnlockTitle,
            AppStrings.snackOfflineFaceUnlockMsg(userName),
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
          Get.offAllNamed(Routes.MAIN_NAV);
        } else {
          OtzarDialog.show(
            title: 'Face ID Verification',
            message: result.message ?? 'Session expired. Please log in with your PIN.',
            type: OtzarDialogType.error,
          );
        }
      }
    } catch (e) {
      isFaceAuthenticating.value = false;
      OtzarDialog.show(
        title: 'Authentication Error',
        message: 'Could not complete biometric authentication: $e',
        type: OtzarDialogType.error,
      );
    }
  }

  /// Submit email and handle new vs existing user flow
  Future<void> submitEmail() async {
    final email = emailTextController.text.trim();

    if (email.isEmpty) {
      HapticFeedback.heavyImpact();
      emailError.value = 'Email address cannot be empty';
      return;
    }

    if (!emailRegex.hasMatch(email)) {
      HapticFeedback.heavyImpact();
      emailError.value = AppStrings.invalidEmailError;
      return;
    }

    emailError.value = null;
    HapticFeedback.lightImpact();
    isLoading.value = true;

    final result = await _authRepository.submitEmail(email);
    isLoading.value = false;

    if (result.isSuccess && result.data != null) {
      final authData = result.data!;

      if (authData.isNewUser) {
        // New User: Show dialog notifying that PIN was sent to email
        HapticFeedback.mediumImpact();
        await OtzarDialog.show(
          title: 'Security PIN Dispatched',
          message:
              'Welcome to OTZAR! A 4-digit Security PIN has been dispatched to ${authData.email}. Please check your inbox to complete verification.',
          confirmText: 'Proceed to PIN',
          type: OtzarDialogType.success,
          onConfirm: () {
            Get.toNamed(
              Routes.PIN_ACCESS,
              arguments: {
                'email': authData.email,
                'is_verified': false,
              },
            );
          },
        );
      } else {
        // Existing User: Navigate directly to PIN screen without resending PIN
        HapticFeedback.lightImpact();
        Get.toNamed(
          Routes.PIN_ACCESS,
          arguments: {
            'email': authData.email,
            'is_verified': authData.isVerified,
          },
        );
      }
    } else {
      HapticFeedback.heavyImpact();
      if (result.message == 'NO_INTERNET_CONNECTION' ||
          (result.message != null && result.message!.toLowerCase().contains('connection error'))) {
        OfflineModeSheet.show(onRetry: submitEmail);
      } else {
        OtzarDialog.show(
          title: 'Authentication Notice',
          message: result.message ?? 'Failed to verify email. Please try again.',
          type: OtzarDialogType.error,
        );
      }
    }
  }

  void onTextChanged(String value) {
    if (emailError.value != null) {
      emailError.value = null;
    }
  }

  @override
  void onClose() {
    emailTextController.dispose();
    super.onClose();
  }
}
