import 'package:flutter/material.dart';
import 'package:wakey/constants/text_theme.dart';
import 'package:wakey/helpers/helper_func.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key, required this.image, required this.title, required this.subtitle
  });
  final String image,title,subtitle;  

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTextTheme.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(0.25),
        child: Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(HelperFunctions.screenWidth(context) * 0.1),
            bottomRight: Radius.circular(HelperFunctions.screenWidth(context) * 0.1),
          ),
          child: Image(
            width: HelperFunctions.screenWidth(context),
            height: HelperFunctions.screenHeight(context) * 0.53,
            fit: BoxFit.cover,
            image: AssetImage(image),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: HelperFunctions.screenWidth(context) * 0.05,
            vertical: HelperFunctions.screenHeight(context) * 0.03,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextTheme.headlineLargeStyle(context).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: HelperFunctions.screenHeight(context) * 0.02),
              Text(
                subtitle,
                style: AppTextTheme.bodyMediumStyle(context).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],),
      ),
    );
  }
}