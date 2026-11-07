import 'package:flutter/material.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';

class CustomerEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final double imageSize;

  const CustomerEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
    this.imageSize = 140,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/cardbox.png',
            width: imageSize,
            height: imageSize,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ],
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 20),
            CustomButton(
              text: actionText!,
              height: 46,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
