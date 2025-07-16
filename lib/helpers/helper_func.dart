import 'package:flutter/material.dart';

class HelperFunctions {
  static void navigateToScreen(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
  static Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
}
