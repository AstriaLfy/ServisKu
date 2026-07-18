import 'package:flutter/material.dart';
import 'package:servis_ku/core/theme/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final Color? backgroundColor;
  final Color? focusedBorderColor;
  final Color? enabledBorderColor;
  final Color? textColor;
  final Color? hintColor;
  final double borderRadius;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.backgroundColor,
    this.focusedBorderColor,
    this.enabledBorderColor,
    this.textColor,
    this.hintColor,
    this.borderRadius = 12,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _obscureText = widget.isPassword;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    // Only dispose if it was created internally
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeBorderColor = widget.focusedBorderColor ?? AppColors.borderFocused;
    final normalBorderColor = widget.enabledBorderColor ?? 
        (isDark ? AppColors.borderNormal : const Color(0xFFD1D5DB));

    // Default background color: fieldBackground in dark theme, transparent in light theme
    final defaultBgColor = isDark ? AppColors.fieldBackground : Colors.transparent;
    final bgColor = widget.backgroundColor ?? defaultBgColor;
    final bool isFilled = bgColor != Colors.transparent;

    // Default text color: White in dark mode, Dark Gray in light mode
    final defaultTextColor = isDark ? AppColors.textPrimary : const Color(0xFF1F2937);
    final txtColor = widget.textColor ?? defaultTextColor;

    // Default hint color: Muted gray in dark mode, Gray in light mode
    final defaultHintColor = isDark ? AppColors.textSecondary : const Color(0xFF9CA3AF);
    final hColor = widget.hintColor ?? defaultHintColor;

    // Suffix icon handling
    Widget? finalSuffixIcon;
    if (widget.isPassword) {
      finalSuffixIcon = IconButton(
        icon: Icon(
          _obscureText 
              ? Icons.visibility_off_outlined 
              : Icons.visibility_outlined,
          color: _obscureText 
              ? hColor 
              : activeBorderColor,
          size: 22,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    } else if (widget.suffixIcon != null) {
      finalSuffixIcon = widget.suffixIcon;
    }

    // Prefix icon handling
    Widget? finalPrefixIcon;
    if (widget.prefixIcon != null) {
      finalPrefixIcon = Icon(
        widget.prefixIcon,
        color: _isFocused 
            ? activeBorderColor 
            : hColor,
        size: 22,
      );
    }

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      style: TextStyle(
        color: _isFocused ? activeBorderColor : txtColor,
        fontSize: 16,
      ),
      cursorColor: activeBorderColor,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: hColor,
          fontSize: 16,
        ),
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: _isFocused ? activeBorderColor : hColor,
          fontSize: 14,
        ),
        prefixIcon: finalPrefixIcon != null 
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: finalPrefixIcon,
              )
            : null,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        suffixIcon: finalSuffixIcon,
        filled: isFilled,
        fillColor: bgColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: normalBorderColor,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: activeBorderColor,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: const BorderSide(
            color: AppColors.borderError,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: const BorderSide(
            color: AppColors.borderError,
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: normalBorderColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
