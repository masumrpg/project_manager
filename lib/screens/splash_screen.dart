
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:project_manager/screens/home_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:project_manager/screens/onboarding_screen.dart';
import 'package:project_manager/services/hive_boxes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<bool> _isOnboardingComplete;

  @override
  void initState() {
    super.initState();
    _isOnboardingComplete = _checkOnboardingStatus();
  }

  Future<bool> _checkOnboardingStatus() async {
    await HiveBoxes.init(); 
    return HiveBoxes.userBox.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isOnboardingComplete,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error initializing app'));
        } else {
          final bool isOnboardingComplete = snapshot.data ?? false;
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
      },
    );
  }
}
