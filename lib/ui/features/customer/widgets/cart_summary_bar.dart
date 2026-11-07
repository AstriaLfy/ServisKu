import 'package:flutter/material.dart';
import 'package:servis_ku/core/theme/app_colors.dart';
import 'package:servis_ku/core/utils/currency_formatter.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';

class CartSummaryBar extends StatelessWidget {
  final int amount;
  final String buttonText;
  final VoidCallback? onPressed;
  final VoidCallback? onBasketTap;
  final int badgeCount;
  final String? label;
  final bool isLoading;
  final bool showBasket;
  final bool showDivider;

  const CartSummaryBar({
    super.key,
    required this.amount,
    required this.buttonText,
    required this.onPressed,
    this.onBasketTap,
    this.badgeCount = 0,
    this.label,
    this.isLoading = false,
    this.showBasket = true,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: showDivider
            ? const Border(top: BorderSide(color: Color(0xFFE5E7EB)))
            : null,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (showBasket) ...[
              GestureDetector(
                onTap: onBasketTap,
                child: Badge(
                  isLabelVisible: badgeCount > 0,
                  label: Text('$badgeCount'),
                  backgroundColor: AppColors.primary,
                  child: const Icon(
                    Icons.shopping_basket_outlined,
                    size: 28,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              const SizedBox(width: 20),
            ],
            if (label != null) ...[
              Text(
                label!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      CurrencyFormatter.format(amount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Text(
                    'harga estimasi',
                    style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            CustomButton(
              text: buttonText,
              width: 140,
              height: 46,
              isLoading: isLoading,
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }
}
