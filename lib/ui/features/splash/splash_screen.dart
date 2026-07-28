import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class AnimatedSplashScreenWidget extends StatelessWidget {
  const AnimatedSplashScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen.withScreenFunction(
      duration: 1500,
      splashIconSize: double.infinity,
      backgroundColor: const Color(0xFF1D56CF),
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
      screenFunction: () async {
        if (context.mounted) {
          context.go('/onboarding');
        }
        return const SizedBox.shrink();
      },
    );
  }
}
