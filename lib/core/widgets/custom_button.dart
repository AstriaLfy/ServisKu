import 'package:flutter/material.dart';
import 'package:servis_ku/core/theme/app_colors.dart';

enum ButtonVariant { filled, outlined, text }
enum ButtonType { primary, danger, custom }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonType type;
  final Color? customColor;
  final Color? customTextColor;
  final double borderRadius;
  final double height;
  final double? width;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.filled,
    this.type = ButtonType.primary,
    this.customColor,
    this.customTextColor,
    this.borderRadius = 30,
    this.height = 50,
    this.width = double.infinity,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    Color backgroundColor;
    Color textColor;
    Color? borderColor;

    // Define base colors
    final Color baseActiveColor = type == ButtonType.primary
        ? AppColors.primary
        : type == ButtonType.danger
            ? AppColors.danger
            : (customColor ?? AppColors.primary);

    final Color baseTextColor = type == ButtonType.primary
        ? AppColors.textPrimary
        : type == ButtonType.danger
            ? AppColors.textPrimary
            : (customTextColor ?? AppColors.textPrimary);

    // Color logic depending on variant
    switch (variant) {
      case ButtonVariant.filled:
        borderColor = null;
        if (isDisabled) {
          if (type == ButtonType.primary) {
            backgroundColor = AppColors.primaryDisabled;
          } else if (type == ButtonType.danger) {
            backgroundColor = AppColors.dangerDisabled;
          } else {
            backgroundColor = baseActiveColor.withValues(alpha: 0.15);
          }
          textColor = baseActiveColor.withValues(alpha: 0.3);
        } else {
          backgroundColor = baseActiveColor;
          textColor = baseTextColor;
        }
        break;

      case ButtonVariant.outlined:
        backgroundColor = Colors.transparent;
        if (isDisabled) {
          borderColor = baseActiveColor.withValues(alpha: 0.2);
          textColor = baseActiveColor.withValues(alpha: 0.3);
        } else {
          borderColor = baseActiveColor;
          textColor = type == ButtonType.custom ? (customTextColor ?? baseActiveColor) : baseActiveColor;
        }
        break;

      case ButtonVariant.text:
        backgroundColor = Colors.transparent;
        borderColor = null;
        if (isDisabled) {
          textColor = baseActiveColor.withValues(alpha: 0.3);
        } else {
          textColor = type == ButtonType.custom ? (customTextColor ?? baseActiveColor) : baseActiveColor;
        }
        break;
    }

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: borderColor != null
              ? BorderSide(color: borderColor, width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          // We can customize highlightColor / splashColor to match theme
          splashColor: baseActiveColor.withValues(alpha: 0.1),
          highlightColor: baseActiveColor.withValues(alpha: 0.05),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: textColor,
                      strokeWidth: 2.0,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (prefixIcon != null) ...[
                          prefixIcon!,
                          const SizedBox(width: 8),
                        ],
                        Text(
                          text,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        if (suffixIcon != null) ...[
                          const SizedBox(width: 8),
                          suffixIcon!,
                        ],
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
