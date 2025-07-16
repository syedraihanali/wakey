import 'package:flutter/material.dart';
import 'package:wakey/constants/text_theme.dart';
import 'package:wakey/features/onboarding/controller/onboarding_controller.dart';
import 'package:wakey/helpers/helper_func.dart';

class OnBoardingNext extends StatelessWidget {
  const OnBoardingNext({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    
    return Positioned(
      bottom: HelperFunctions.screenHeight(context) * 0.1,
      left: HelperFunctions.screenWidth(context) * 0.05,
      right: HelperFunctions.screenWidth(context) * 0.05,
      child: SizedBox(
        width: HelperFunctions.screenWidth(context) * 0.90,
        child: ElevatedButton(
          onPressed: () {
            // Logic to go to the next page
            OnBoardingController.instance.nextPage();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTextTheme.primaryButton,
            padding: EdgeInsets.symmetric(
              vertical: HelperFunctions.screenHeight(context) * 0.02,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                HelperFunctions.screenWidth(context) * 0.025,
              ),
            ),
          ),
          child: Text(
            "Next",
            style: TextStyle(
              fontFamily: 'Oxygen',
              fontWeight: FontWeight.w700,
              fontSize: HelperFunctions.screenWidth(context) * 0.045,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
