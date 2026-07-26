import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../onboarding/onboarding_page.dart';

class AnimatedSplashScreenWidget extends StatelessWidget {
  const AnimatedSplashScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration:
          3000, // durasi splash tampil (ms), sesuaiin sama panjang animasi
      splashIconSize: double
          .infinity, // <- WAJIB, biar splash-nya gak dibatasi ukuran default package
      backgroundColor: Colors.black,
      splash: ClipRect(
        child: SizedBox.expand(
          // <- full screen sesuai ukuran HP
          child: FittedBox(
            fit: BoxFit.cover, // <- crop otomatis biar full, gak ada bar hitam
            child: Transform.scale(
              scale:
                  1.1, // <- opsional, kalau mau crop dikit lagi dari full cover
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
