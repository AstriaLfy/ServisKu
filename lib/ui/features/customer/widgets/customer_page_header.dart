import 'package:flutter/material.dart';
import 'package:servis_ku/core/theme/app_colors.dart';

class CustomerBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const CustomerBackButton({
    super.key,
    this.onTap,
    this.size = 36,
    this.backgroundColor = AppColors.primary,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: backgroundColor == AppColors.primary
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Icon(Icons.arrow_back, color: iconColor, size: size * 0.5),
      ),
    );
  }
}

class CustomerPageHeader extends StatelessWidget {
  final String title;
  final bool centerTitle;
  final double fontSize;
  final VoidCallback? onBack;
  final EdgeInsetsGeometry padding;

  const CustomerPageHeader({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.fontSize = 18,
    this.onBack,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 16),
  });

  @override
  Widget build(BuildContext context) {
    final titleText = Text(
      title,
      textAlign: centerTitle ? TextAlign.center : TextAlign.start,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF111827),
      ),
    );

    return Padding(
      padding: padding,
      child: Row(
        children: [
          CustomerBackButton(onTap: onBack),
          if (centerTitle) ...[
            Expanded(child: titleText),
            const SizedBox(width: 36),
          ] else ...[
            const SizedBox(width: 16),
            Expanded(child: titleText),
          ],
        ],
      ),
    );
  }
}
