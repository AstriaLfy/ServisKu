import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../onboarding/onboarding_page.dart';

class AnimatedSplashScreenWidget extends StatelessWidget {
  const AnimatedSplashScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 3000,
      splashIconSize: double.infinity,
      backgroundColor: Colors.black,
      splash: ClipRect(
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: Transform.scale(
              scale: 1.1,
              child: Lottie.asset(
                'assets/videos/splashscreen.json',
                repeat: false,
              ),
            ),
          ),
        ),
      ),
      nextScreen: const OnboardingPage(),
    );
  }
}
