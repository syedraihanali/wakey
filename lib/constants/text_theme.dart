import 'package:flutter/material.dart';

class AppTextTheme {
  // Font family
  static const String fontFamily = 'Oxygen';
  
  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight bold = FontWeight.w700;
  
  // Theme colors
  static const Color backgroundColor = Color(0xFF212327);
  static const Color primaryButton = Color(0xFF7B4CDF);
  static const Color secondaryButton = Color(0xFF858485);
  static const Color specialButton = Color(0xFF4D4D4D);
  
  // Responsive font sizes based on screen width
  static double displayLarge(BuildContext context) => MediaQuery.of(context).size.width * 0.12;
  static double displayMedium(BuildContext context) => MediaQuery.of(context).size.width * 0.10;
  static double displaySmall(BuildContext context) => MediaQuery.of(context).size.width * 0.08;
  
  static double headlineLarge(BuildContext context) => MediaQuery.of(context).size.width * 0.07;
  static double headlineMedium(BuildContext context) => MediaQuery.of(context).size.width * 0.06;
  static double headlineSmall(BuildContext context) => MediaQuery.of(context).size.width * 0.05;
  
  static double titleLarge(BuildContext context) => MediaQuery.of(context).size.width * 0.055;
  static double titleMedium(BuildContext context) => MediaQuery.of(context).size.width * 0.045;
  static double titleSmall(BuildContext context) => MediaQuery.of(context).size.width * 0.04;
  
  static double bodyLarge(BuildContext context) => MediaQuery.of(context).size.width * 0.042;
  static double bodyMedium(BuildContext context) => MediaQuery.of(context).size.width * 0.038;
  static double bodySmall(BuildContext context) => MediaQuery.of(context).size.width * 0.035;
  
  static double labelLarge(BuildContext context) => MediaQuery.of(context).size.width * 0.038;
  static double labelMedium(BuildContext context) => MediaQuery.of(context).size.width * 0.035;
  static double labelSmall(BuildContext context) => MediaQuery.of(context).size.width * 0.032;
  
  // Text styles with custom font
  static TextStyle displayLargeStyle(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: displayLarge(context),
    fontWeight: bold,
    height: 1.2,
  );
  
  static TextStyle displayMediumStyle(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: displayMedium(context),
    fontWeight: bold,
    height: 1.2,
  );
  
  static TextStyle displaySmallStyle(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: displaySmall(context),
    fontWeight: medium,
    height: 1.2,
  );
  
  static TextStyle headlineLargeStyle(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: headlineLarge(context),
    fontWeight: medium,
    height: 1.3,
  );
  
  static TextStyle headlineMediumStyle(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: headlineMedium(context),
    fontWeight: medium,
    height: 1.3,
  );
  
  static TextStyle headlineSmallStyle(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: headlineSmall(context),
    fontWeight: medium,
    height: 1.3,
  );
  
  static TextStyle titleLargeStyle(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: titleLarge(context),
    fontWeight: medium,
    height: 1.4,
  );
  
  static TextStyle titleMediumStyle(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: titleMedium(context),
    fontWeight: medium,
    height: 1.4,
  );
  
  static TextStyle titleSmallStyle(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: titleSmall(context),
    fontWeight: regular,
    height: 1.4,
  );
  
  static TextStyle bodyLargeStyle(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: bodyLarge(context),
    fontWeight: regular,
    height: 1.5,
  );
  
  static TextStyle bodyMediumStyle(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: bodyMedium(context),
    fontWeight: regular,
    height: 1.5,
  );
  
  static TextStyle bodySmallStyle(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: bodySmall(context),
    fontWeight: regular,
    height: 1.5,
  );
  
  static TextStyle labelLargeStyle(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: labelLarge(context),
    fontWeight: medium,
    height: 1.6,
  );
  
  static TextStyle labelMediumStyle(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: labelMedium(context),
    fontWeight: regular,
    height: 1.6,
  );
  
  static TextStyle labelSmallStyle(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: labelSmall(context),
    fontWeight: regular,
    height: 1.6,
  );
}
