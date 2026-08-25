import 'package:flutter/services.dart';
import 'package:get/get.dart';

class MainNavController extends GetxController {
  final currentIndex = 0.obs;
  final stagedCount = 3.obs;

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
