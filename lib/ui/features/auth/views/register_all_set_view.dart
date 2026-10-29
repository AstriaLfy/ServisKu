import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';
import 'package:servis_ku/features/auth/domain/user_role.dart';
import 'package:servis_ku/ui/features/auth/bloc/auth_bloc.dart';

class RegisterAllSetView extends StatelessWidget {
  final String fullName;
  final String? selectedRole;

  const RegisterAllSetView({
    super.key,
    this.fullName = '',
    this.selectedRole,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
            ),
          );
        } else if (state is AuthSuccess) {
          // Arahkan ke beranda sesuai role
          if (state.user.role == UserRole.provider) {
            context.go('/provider/beranda');
          } else {
            context.go('/customer/home');
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
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
                        isLoading: isLoading,
                        onPressed: isLoading
                            ? null
                            : () {
                                final role = UserRole.fromString(selectedRole);
                                context.read<AuthBloc>().add(
                                      ProfileUpdateRequested(
                                        fullName: fullName,
                                        role: role,
                                      ),
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
      },
    );
  }
}
