
import 'package:flutter/material.dart';
import 'package:wakey/features/onboarding/controller/onboarding_controller.dart';


class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: kToolbarHeight - 2, 
      right: 16, 
      child: TextButton(
        onPressed: () => OnBoardingController.instance.skipPage(), 
        child: const Text(
          'Skip',
          style: TextStyle(
            fontFamily: 'Oxygen',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
