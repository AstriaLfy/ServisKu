import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';
import 'onboarding_data.dart';
import 'package:servis_ku/core/widgets/progress_bar.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const int _welcomeIndex = 3;

  void _goToNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToWelcome() {
    _pageController.animateToPage(
      _welcomeIndex,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWelcomePage = _currentIndex == _welcomeIndex;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            if (!isWelcomePage)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    if (_currentIndex > 0)
                      GestureDetector(
                        onTap: _goToPrevious,
                        child: const Icon(Icons.arrow_back_ios_new, size: 18),
                      )
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 60,
                      child: StepProgressBar(
                        totalSteps: onboardingItems.length,
                        currentStep: _currentIndex,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _skipToWelcome,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: onboardingItems.length + 1,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  if (index == _welcomeIndex) {
                    return _WelcomePage(
                      onLogin: () {
                        context.push('/login');
                      },
                      onRegister: () {
                        context.push('/register');
                      },
                    );
                  }

                  final item = onboardingItems[index];
                  return _OnboardingSlide(item: item, onNext: _goToNext);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final OnboardingData item;
  final VoidCallback onNext;

  const _OnboardingSlide({required this.item, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomSafeArea),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Image.asset(item.image, fit: BoxFit.contain),
          ),
          const SizedBox(height: 24),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const Spacer(),
          CustomButton(text: 'Lanjut', onPressed: onNext),
        ],
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const _WelcomePage({required this.onLogin, required this.onRegister});

  @override
  Widget build(BuildContext context) {
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: -50,
          right: -50,
          child: Transform.scale(
            scale: 1,
            child: Image.asset(
              'assets/images/texture2.png',
              width: MediaQuery.of(context).size.width * 1.2,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 16 + bottomSafeArea),
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Selamat Datang di\nServisKu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login/signup menggunakan akun ServisKu',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 24),
                CustomButton(text: 'Log In', onPressed: onLogin),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Register',
                  variant: ButtonVariant.outlined,
                  onPressed: onRegister,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
