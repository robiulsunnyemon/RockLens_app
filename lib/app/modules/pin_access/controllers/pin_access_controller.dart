import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/widgets/offline_mode_sheet.dart';
import '../../../core/widgets/otzar_dialog.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../routes/app_pages.dart';

class PinAccessController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final StorageService _storage = Get.find<StorageService>();

  final pin = ''.obs;
  final isShaking = false.obs;
  final isError = false.obs;
  final isLoading = false.obs;
  final operatorEmail = RxnString();
  final isVerified = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Map) {
      if (Get.arguments['email'] != null) {
        operatorEmail.value = Get.arguments['email'] as String;
      }
      if (Get.arguments['is_verified'] != null) {
        isVerified.value = Get.arguments['is_verified'] as bool;
      }
    } else {
      operatorEmail.value = _storage.lastEmail ?? 'operator@otzar.geocore';
      isVerified.value = _storage.currentUser?.isVerified ?? false;
    }
  }

  void changeEmail() {
    Get.back();
  }

  void onKeyPressed(String key) {
    if (isLoading.value || key.isEmpty) return;

    if (key == '⌫') {
      if (pin.value.isNotEmpty) {
        HapticFeedback.lightImpact();
        pin.value = pin.value.substring(0, pin.value.length - 1);
      }
      return;
    }

    if (pin.value.length < 4) {
      HapticFeedback.selectionClick();
      pin.value += key;

      if (pin.value.length == 4) {
        _validatePin();
      }
    }
  }

  Future<void> _validatePin() async {
    final enteredPin = pin.value;
    final email = operatorEmail.value ?? 'operator@otzar.geocore';

    isLoading.value = true;

    // Strict backend API validation only - No dummy bypass
    final result = await _authRepository.verifyPin(
      email: email,
      pin: enteredPin,
    );

    isLoading.value = false;

    if (result.isSuccess && result.data != null) {
      HapticFeedback.mediumImpact();
      Get.offAllNamed(Routes.HOME);
    } else {
      HapticFeedback.heavyImpact();
      isShaking.value = true;
      isError.value = true;

      Timer(const Duration(milliseconds: 600), () {
        isShaking.value = false;
        pin.value = '';
        isError.value = false;
      });

      if (result.message == 'NO_INTERNET_CONNECTION' ||
          (result.message != null && result.message!.toLowerCase().contains('connection error'))) {
        OfflineModeSheet.show(onRetry: _validatePin);
      } else {
        // Show Dialog Box notifying user of incorrect PIN
        OtzarDialog.show(
          title: 'Invalid Security PIN',
          message: result.message ??
              'The 4-digit PIN entered is invalid or expired. Please check your email and try again, or request a reset.',
          confirmText: 'Try Again',
          type: OtzarDialogType.error,
        );
      }
    }
  }

  /// For unverified operators (is_verified == false)
  Future<void> resendPin() async {
    final email = operatorEmail.value;
    if (email == null || email.isEmpty) return;

    HapticFeedback.lightImpact();
    isLoading.value = true;

    final result = await _authRepository.resendPin(email);
    isLoading.value = false;

    if (result.isSuccess) {
      OtzarDialog.show(
        title: 'Security PIN Dispatched',
        message:
            'A fresh 4-digit security PIN has been transmitted to $email. Please check your inbox.',
        confirmText: 'OK',
        type: OtzarDialogType.success,
      );
    } else {
      OtzarDialog.show(
        title: 'Resend Failed',
        message: result.message ?? 'Failed to resend PIN. Please try again.',
        confirmText: 'Close',
        type: OtzarDialogType.error,
      );
    }
  }

  /// For verified operators (is_verified == true)
  Future<void> resetPin() async {
    final email = operatorEmail.value;
    if (email == null || email.isEmpty) return;

    HapticFeedback.mediumImpact();
    isLoading.value = true;

    final result = await _authRepository.resetPin(email);
    isLoading.value = false;

    if (result.isSuccess) {
      OtzarDialog.show(
        title: 'PIN Reset Code Sent',
        message:
            'A temporary 4-digit reset code has been dispatched to $email. Please enter it to reset your field access.',
        confirmText: 'OK',
        type: OtzarDialogType.success,
      );
    } else {
      OtzarDialog.show(
        title: 'Reset Failed',
        message: result.message ?? 'Failed to initiate PIN reset. Please try again.',
        confirmText: 'Close',
        type: OtzarDialogType.error,
      );
    }
  }

  void onBiometricAuth() {
    if (_storage.isAuthenticated) {
      HapticFeedback.mediumImpact();
      Get.offAllNamed(Routes.HOME);
    } else {
      HapticFeedback.heavyImpact();
      OtzarDialog.show(
        title: 'Biometric Access',
        message: 'Please authenticate with your 4-digit security PIN first to establish a secure vault session.',
        confirmText: 'OK',
        type: OtzarDialogType.info,
      );
    }
  }
}
