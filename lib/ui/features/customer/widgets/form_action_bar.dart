import 'package:flutter/material.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';

class FormActionBar extends StatelessWidget {
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isLoading;

  const FormActionBar({
    super.key,
    required this.confirmText,
    required this.onConfirm,
    this.cancelText = 'Batalkan',
    this.onCancel,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: cancelText,
              variant: ButtonVariant.outlined,
              height: 46,
              onPressed: isLoading
                  ? null
                  : (onCancel ?? () => Navigator.of(context).maybePop()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              text: confirmText,
              height: 46,
              isLoading: isLoading,
              onPressed: isLoading ? null : onConfirm,
            ),
          ),
        ],
      ),
    );
  }
}
