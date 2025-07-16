import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wakey/constants/text_theme.dart';
import 'package:wakey/features/onboarding/screens/onboarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
    
    // Navigate to onboarding after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      Get.off(() => const OnBoarding());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTextTheme.backgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: _animation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.alarm,
                    size: 80,
                    color: AppTextTheme.primaryButton,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Wakey',
                    style: AppTextTheme.displayMediumStyle(context).copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Personalized alarm app',
                    style: AppTextTheme.bodyMediumStyle(context).copyWith(
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
