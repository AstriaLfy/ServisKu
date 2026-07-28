import 'package:flutter/material.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';
import 'package:servis_ku/ui/features/auth/views/login_view.dart';

class RegisterAllSetView extends StatelessWidget {
  final String? selectedRole;

  const RegisterAllSetView({
    super.key,
    this.selectedRole,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Large top texture banner covering ~45% of height (as in Image 4)
          SizedBox(
            width: double.infinity,
            height: screenHeight * 0.45,
            child: Image.asset(
              'assets/images/texture.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Sudah siap!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Nikmati fitur-fitur lengkap pada\nServisku!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),

                  const Spacer(),

                  CustomButton(
                    text: 'Lanjut',
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginView(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
