import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wakey/constants/image_strings.dart';
import 'package:wakey/constants/text_strings.dart';
import 'package:wakey/constants/text_theme.dart';
import 'package:wakey/features/onboarding/controller/onboarding_controller.dart';
import 'package:wakey/features/onboarding/widgets/dot_navigation.dart';
import 'package:wakey/features/onboarding/widgets/onboarding_next.dart';
import 'package:wakey/features/onboarding/widgets/onboarding_page.dart';
import 'package:wakey/features/onboarding/widgets/onboarding_skip.dart';


class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());
    return Scaffold(
      backgroundColor: AppTextTheme.backgroundColor,
      body: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePage,
            children: [
              OnBoardingPage(
                image: ImageStrings.onboardingImage1,
                title: TextStrings.onboardingTitle1,
                subtitle: TextStrings.onboardingSubtitle1,
              ),
              OnBoardingPage(
                image: ImageStrings.onboardingImage2,
                title: TextStrings.onboardingTitle2,
                subtitle: TextStrings.onboardingSubtitle2,
              ),
              OnBoardingPage(
                image: ImageStrings.onboardingImage3,
                title: TextStrings.onboardingTitle3,
                subtitle: TextStrings.onboardingSubtitle3,
              ),
            ],
          ),
          
          const OnBoardingSkip(),
          NavigationDots(),
          OnBoardingNext(),
        ],
      ),
    );
  }
}

