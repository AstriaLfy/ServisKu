import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../onboarding/onboarding_page.dart';

class AnimatedSplashScreenWidget extends StatelessWidget {
  const AnimatedSplashScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(child: Lottie.asset('assets/videos/splashscreen.json`')),
      nextScreen: const OnboardingPage(),
    );
  }
}
