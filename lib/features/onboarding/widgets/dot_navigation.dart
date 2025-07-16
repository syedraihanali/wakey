import 'package:flutter/material.dart';
import 'package:wakey/constants/text_theme.dart';
import 'package:wakey/features/onboarding/controller/onboarding_controller.dart';
import 'package:wakey/helpers/helper_func.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class NavigationDots extends StatelessWidget {
  const NavigationDots({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;
    
    return Positioned(
      bottom: HelperFunctions.screenHeight(context) * 0.20,
      left: 0,
      right: 0,
      child: Center(
        child: SmoothPageIndicator(
          controller: controller.pageController,
          count: 3,
          effect: WormEffect(
            dotHeight: HelperFunctions.screenWidth(context) * 0.025,
            dotWidth: HelperFunctions.screenWidth(context) * 0.025,
            spacing: HelperFunctions.screenWidth(context) * 0.020,
            activeDotColor: AppTextTheme.primaryButton,
            dotColor: AppTextTheme.secondaryButton,
          ),
        ),
      ),
    );
  }
}

