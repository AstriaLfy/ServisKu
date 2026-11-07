import 'package:flutter/material.dart';
import 'package:servis_ku/core/widgets/custom_text_field.dart';

class LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final bool isPassword;
  final bool enabled;
  final IconData? prefixIcon;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.isPassword = false,
    this.enabled = true,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          hintText: hintText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          isPassword: isPassword,
          enabled: enabled,
          prefixIcon: prefixIcon,
        ),
      ],
    );
  }
}
