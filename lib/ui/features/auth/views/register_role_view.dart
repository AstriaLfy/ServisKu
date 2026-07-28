import 'package:flutter/material.dart';
import 'package:servis_ku/core/theme/app_colors.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';
import 'package:servis_ku/ui/features/auth/views/register_all_set_view.dart';

class RegisterRoleView extends StatefulWidget {
  const RegisterRoleView({super.key});

  @override
  State<RegisterRoleView> createState() => _RegisterRoleViewState();
}

class _RegisterRoleViewState extends State<RegisterRoleView> {
  String? _selectedRole; // 'provider' or 'customer'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top texture banner
            SizedBox(
              width: double.infinity,
              height: 180,
              child: Opacity(
                opacity: 0.35,
                child: Image.asset(
                  'assets/images/texture.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Peran kamu?',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'Pemilik jasa? atau pengguna jasa?',
                      style: TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Role cards row
                    Row(
                      children: [
                        Expanded(
                          child: _buildRoleCard(
                            roleKey: 'provider',
                            title: 'Pemilik Jasa',
                            imageAsset: 'assets/images/provider.png',
                            isSelected: _selectedRole == 'provider',
                            onTap: () {
                              setState(() {
                                _selectedRole = 'provider';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildRoleCard(
                            roleKey: 'customer',
                            title: 'Pengguna Jasa',
                            imageAsset: 'assets/images/user.png',
                            isSelected: _selectedRole == 'customer',
                            onTap: () {
                              setState(() {
                                _selectedRole = 'customer';
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    CustomButton(
                      text: 'Lanjut',
                      onPressed: _selectedRole != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterAllSetView(
                                    selectedRole: _selectedRole,
                                  ),
                                ),
                              );
                            }
                          : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String roleKey,
    required String title,
    required String imageAsset,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final activeColor = AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE5E7EB),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Column(
            children: [
              // Top illustration area
              Container(
                width: double.infinity,
                height: 170,
                color: const Color(0xFFEFF6FF),
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.contain,
                ),
              ),

              // Bottom label container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : const Color(0xFFEFF6FF),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.white : const Color(0xFFD1D5DB),
                      ),
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: isSelected ? activeColor : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
