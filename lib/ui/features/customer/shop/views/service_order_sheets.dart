import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servis_ku/core/theme/app_colors.dart';
import 'package:servis_ku/core/utils/currency_formatter.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';
import 'package:servis_ku/ui/features/customer/shop/bloc/cart_cubit.dart';
import 'package:servis_ku/ui/features/customer/shop/bloc/cart_state.dart';
import 'package:servis_ku/ui/features/customer/shop/domain/shop_service.dart';
import 'package:servis_ku/ui/features/customer/widgets/cart_summary_bar.dart';
import 'package:servis_ku/ui/features/customer/widgets/quantity_stepper.dart';

const _sheetShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
);

Future<int?> showServiceQuantitySheet(
  BuildContext context, {
  required ShopService service,
  required int initialQuantity,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: _sheetShape,
    builder: (sheetContext) => _ServiceQuantitySheet(
      service: service,
      initialQuantity: initialQuantity,
    ),
  );
}

Future<void> showCartSheet(
  BuildContext context, {
  required bool canCheckout,
  required VoidCallback onCheckout,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: _sheetShape,
    builder: (sheetContext) => _CartSheet(
      canCheckout: canCheckout,
      onCheckout: () {
        Navigator.of(sheetContext).pop();
        onCheckout();
      },
    ),
  );
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _ServiceQuantitySheet extends StatefulWidget {
  final ShopService service;
  final int initialQuantity;

  const _ServiceQuantitySheet({
    required this.service,
    required this.initialQuantity,
  });

  @override
  State<_ServiceQuantitySheet> createState() => _ServiceQuantitySheetState();
}

class _ServiceQuantitySheetState extends State<_ServiceQuantitySheet> {
  late int _quantity = widget.initialQuantity;

  @override
  Widget build(BuildContext context) {
    final service = widget.service;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.subtitle,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        CurrencyFormatter.format(service.price),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                QuantityStepper(
                  value: _quantity,
                  onChanged: (value) => setState(() => _quantity = value),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Align(
              alignment: Alignment.centerRight,
              child: CustomButton(
                text: 'Konfirmasi',
                width: 140,
                height: 46,
                onPressed: () => Navigator.of(context).pop(_quantity),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartSheet extends StatelessWidget {
  final bool canCheckout;
  final VoidCallback onCheckout;

  const _CartSheet({required this.canCheckout, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    final maxListHeight = MediaQuery.sizeOf(context).height * 0.45;

    return BlocConsumer<CartCubit, CartState>(
      listenWhen: (prev, curr) => !prev.isEmpty && curr.isEmpty,
      listener: (context, state) => Navigator.of(context).pop(),
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: _SheetHandle(),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                'Daftar Pesanan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxListHeight),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                itemCount: state.items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.service.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(item.service.price),
                              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ),
                      QuantityStepper(
                        value: item.quantity,
                        onChanged: (value) => context
                            .read<CartCubit>()
                            .updateQuantity(item.service.id, value),
                      ),
                    ],
                  );
                },
              ),
            ),
            CartSummaryBar(
              amount: state.totalPrice,
              buttonText: 'Checkout',
              badgeCount: state.totalQuantity,
              onPressed: canCheckout && !state.isEmpty ? onCheckout : null,
            ),
          ],
        );
      },
    );
  }
}
