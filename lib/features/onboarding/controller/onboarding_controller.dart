import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentIndex = 0.obs;

  int get lastIndex => 2; // update if number of pages changes

  void nextPage() {
    final next = currentIndex.value + 1;
    if (next <= lastIndex) {
      pageController.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      currentIndex.value = next;
    }
  }

  void previousPage() {
    final prev = currentIndex.value - 1;
    if (prev >= 0) {
      pageController.animateToPage(prev, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
      currentIndex.value = prev;
    }
  }

  void jumpToPage(int index) {
    pageController.animateToPage(index, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    currentIndex.value = index;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
