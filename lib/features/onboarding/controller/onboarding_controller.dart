import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:wakey/features/permissions/lp_screen.dart';

class OnBoardingController extends GetxController {
  static OnBoardingController get instance => Get.find();

  final pageController = PageController();
  RxInt currentPageIndex = 0.obs;

  void updatePage(int index) => currentPageIndex.value = index;

  
  void nextPage() {
    if(currentPageIndex.value == 2){
      // Navigate to location permission screen
      Get.to(() => const LocationPermissionScreen());
    }
    else {
      currentPageIndex.value++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void skipPage() {
    // Navigate directly to location permission screen
    Get.to(() => const LocationPermissionScreen());
  }
}