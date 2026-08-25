import 'package:flutter/services.dart';
import 'package:get/get.dart';

class MainNavController extends GetxController {
  final currentIndex = 0.obs;
  final stagedCount = 3.obs;

  @override
  void onInit() {
    super.onInit();
    _handleArguments();
  }

  void _handleArguments() {
    if (Get.arguments is Map && Get.arguments['tab'] != null) {
      final tab = Get.arguments['tab'];
      if (tab is int && tab >= 0 && tab <= 4) {
        currentIndex.value = tab;
      }
    }
  }

  void changePage(int index) {
    if (currentIndex.value != index) {
      HapticFeedback.selectionClick();
      currentIndex.value = index;
    }
  }

  void navigateToTab(int index) {
    changePage(index);
  }
}
