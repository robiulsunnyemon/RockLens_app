import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_strings.dart';
import '../../../routes/app_pages.dart';

class OnboardingSlideModel {
  final String tag;
  final String title;
  final String description;
  final int slideIndex;

  const OnboardingSlideModel({
    required this.tag,
    required this.title,
    required this.description,
    required this.slideIndex,
  });
}

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentIndex = 0.obs;

  final List<OnboardingSlideModel> slides = const [
    OnboardingSlideModel(
      tag: AppStrings.slide1Tag,
      title: AppStrings.slide1Title,
      description: AppStrings.slide1Desc,
      slideIndex: 0,
    ),
    OnboardingSlideModel(
      tag: AppStrings.slide2Tag,
      title: AppStrings.slide2Title,
      description: AppStrings.slide2Desc,
      slideIndex: 1,
    ),
    OnboardingSlideModel(
      tag: AppStrings.slide3Tag,
      title: AppStrings.slide3Title,
      description: AppStrings.slide3Desc,
      slideIndex: 2,
    ),
  ];

  bool get isLastSlide => currentIndex.value == slides.length - 1;

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  void proceedToEmailAccess() {
    Get.offNamed(Routes.EMAIL_ACCESS);
    // Get.offNamed(Routes.MAIN_NAV);
  }

  void next() {
    if (!isLastSlide) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      proceedToEmailAccess();
    }
  }

  void goToSlide(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void skip() {
    proceedToEmailAccess();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
