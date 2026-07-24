import 'package:flutter/material.dart';
import 'package:servis_ku/core/theme/app_colors.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';
import 'package:servis_ku/core/widgets/custom_text_field.dart';

class DesignSystemPreview extends StatefulWidget {
  const DesignSystemPreview({super.key});

  @override
  State<DesignSystemPreview> createState() => _DesignSystemPreviewState();
}

class _DesignSystemPreviewState extends State<DesignSystemPreview> {
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Design System Preview',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- BUTTONS SECTION ---
              _buildSectionHeader('Buttons'),
              const SizedBox(height: 16),
              
              const Text(
                'Primary (Blue) Variants',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              // Filled Button
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Konfirmasi',
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Disabled',
                      onPressed: null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),


              // Outlined Button
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Konfirmasi',
                      variant: ButtonVariant.outlined,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Disabled',
                      variant: ButtonVariant.outlined,
                      onPressed: null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Text Button
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Konfirmasi',
                      variant: ButtonVariant.text,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Disabled',
                      variant: ButtonVariant.text,
                      onPressed: null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Secondary/Danger (Red) Variants',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              // Danger Filled Button
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Konfirmasi',
                      type: ButtonType.danger,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Disabled',
                      type: ButtonType.danger,
                      onPressed: null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Danger Outlined Button
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Konfirmasi',
                      variant: ButtonVariant.outlined,
                      type: ButtonType.danger,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Disabled',
                      variant: ButtonVariant.outlined,
                      type: ButtonType.danger,
                      onPressed: null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- TEXT FIELDS SECTION ---
              _buildSectionHeader('Fields'),
              const SizedBox(height: 16),

              const Text(
                'Password Field (isPassword = true)',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _passwordController,
                hintText: 'Kata Sandi',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 24),

              const Text(
                'Name Field (Ordinary Text)',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _nameController,
                hintText: 'Nama',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 24),

              const Text(
                'Phone Field (Phone Keyboard)',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _phoneController,
                hintText: 'Nomor Telepon',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
      ],
    );
  }
}