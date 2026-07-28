import 'package:flutter/material.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';
import 'package:servis_ku/core/widgets/custom_text_field.dart';
import 'package:servis_ku/ui/features/auth/views/register_role_view.dart';

class RegisterNameView extends StatefulWidget {
  const RegisterNameView({super.key});

  @override
  State<RegisterNameView> createState() => _RegisterNameViewState();
}

class _RegisterNameViewState extends State<RegisterNameView> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isNameValid => _nameController.text.trim().isNotEmpty;

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
                      'Kenalan dulu yuk!',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      'Siapakah namamu?',
                      style: TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

                    CustomTextField(
                      controller: _nameController,
                      hintText: 'Masukkan nama kamu',
                      prefixIcon: Icons.person_outline,
                      borderRadius: 16,
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),

                    const Spacer(),

                    CustomButton(
                      text: 'Lanjut',
                      onPressed: _isNameValid
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterRoleView(),
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
}
