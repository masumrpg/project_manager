
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:project_manager/screens/home_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:project_manager/screens/onboarding_screen.dart';
import 'package:project_manager/services/hive_boxes.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isOnboardingComplete = HiveBoxes.userBox.isNotEmpty;

    return AnimatedSplashScreen(
      splash: Image.asset('assets/images/logo.png'),
      nextScreen: isOnboardingComplete
          ? const HomeScreen()
          : const OnboardingScreen(),
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
      backgroundColor: const Color(0xFFFFFBF7),
      duration: 1800,
    );
  }
}
