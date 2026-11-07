import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_ku/core/theme/app_colors.dart';
import 'package:servis_ku/core/utils/currency_formatter.dart';
import 'package:servis_ku/core/widgets/custom_text_field.dart';
import 'package:servis_ku/core/widgets/detail_info_card.dart';
import 'package:servis_ku/ui/features/auth/bloc/auth_bloc.dart';
import 'package:servis_ku/ui/features/customer/address/bloc/address_cubit.dart';
import 'package:servis_ku/ui/features/customer/address/bloc/address_state.dart';
import 'package:servis_ku/ui/features/customer/address/domain/customer_address.dart';
import 'package:servis_ku/ui/features/customer/booking/bloc/booking_cubit.dart';
import 'package:servis_ku/ui/features/customer/booking/bloc/booking_state.dart';
import 'package:servis_ku/ui/features/customer/booking/domain/booking_pricing.dart';
import 'package:servis_ku/ui/features/customer/booking/domain/payment_method.dart';
import 'package:servis_ku/ui/features/customer/order/bloc/customer_order_cubit.dart';
import 'package:servis_ku/ui/features/customer/shop/bloc/cart_cubit.dart';
import 'package:servis_ku/ui/features/customer/shop/bloc/cart_state.dart';
import 'package:servis_ku/ui/features/customer/shop/domain/cart_item.dart';
import 'package:servis_ku/ui/features/customer/widgets/cart_summary_bar.dart';
import 'package:servis_ku/ui/features/customer/widgets/customer_page_header.dart';
import 'package:servis_ku/ui/features/customer/widgets/price_summary.dart';
import 'package:servis_ku/ui/features/customer/widgets/quantity_stepper.dart';
import 'package:servis_ku/ui/features/customer/widgets/service_thumbnail.dart';

class OrderConfirmationView extends StatefulWidget {
  const OrderConfirmationView({super.key});

  @override
  State<OrderConfirmationView> createState() => _OrderConfirmationViewState();
}

class _OrderConfirmationViewState extends State<OrderConfirmationView> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _noteController.text = context.read<BookingCubit>().state.note;
    final addressCubit = context.read<AddressCubit>();
    if (addressCubit.state.status != AddressStatus.loaded) {
      addressCubit.load();
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _onBookingChanged(BuildContext context, BookingState state) {
    if (state.status == BookingStatus.failure && state.errorMessage != null) {
      _showMessage(state.errorMessage!);
      return;
    }

    if (state.status == BookingStatus.success && state.createdOrderId != null) {
      final router = GoRouter.of(context);
      final cartCubit = context.read<CartCubit>();
      final orderCubit = context.read<CustomerOrderCubit>();
      final orderLocation = '/customer/order/${state.createdOrderId}';

      _showMessage('Pesanan berhasil dibuat. Menunggu konfirmasi penyedia jasa.');
      router.go('/customer/riwayat');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        router.push(orderLocation);
        cartCubit.clear();
      });
      orderCubit.loadOrders();
    }
  }

  Future<void> _pickPaymentMethod(PaymentMethod current) async {
    final selected = await showModalBottomSheet<PaymentMethod>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Metode Pembayaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              ...PaymentMethod.values.map(
                (method) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(method.icon, color: AppColors.primary),
                  title: Text(
                    method.label,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
                  ),
                  trailing: Icon(
                    method == current
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: method == current ? AppColors.primary : const Color(0xFF9CA3AF),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop(method),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (selected != null && mounted) {
      context.read<BookingCubit>().setPaymentMethod(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingCubit, BookingState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status || prev.errorMessage != curr.errorMessage,
      listener: _onBookingChanged,
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, cart) {
          final lines = cart.items
              .map((item) => PriceLine(item.summaryLabel, item.subtotal))
              .toList();

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const CustomerPageHeader(
                    title: 'Konfirmasi Order',
                    centerTitle: false,
                    fontSize: 20,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _AddressTile(),
                          const SizedBox(height: 16),
                          _buildOrderDetail(context, cart),
                          if (!cart.isEmpty) ...[
                            const SizedBox(height: 16),
                            DetailInfoCard(
                              title: 'Detail Harga',
                              child: PriceSummary(lines: lines),
                            ),
                          ],
                          const SizedBox(height: 20),
                          BlocBuilder<BookingCubit, BookingState>(
                            buildWhen: (prev, curr) => prev.paymentMethod != curr.paymentMethod,
                            builder: (context, booking) => _PaymentTile(
                              method: booking.paymentMethod,
                              onTap: () => _pickPaymentMethod(booking.paymentMethod),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Catatan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Tuliskan catatan untuk penyedia jasa jika diperlukan.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: _noteController,
                            hintText: 'Tuliskan catatan',
                            textInputAction: TextInputAction.done,
                            onChanged: context.read<BookingCubit>().setNote,
                          ),
                        ],
                      ),
                    ),
                  ),
                  BlocBuilder<BookingCubit, BookingState>(
                    builder: (context, booking) {
                      return BlocBuilder<AddressCubit, AddressState>(
                        builder: (context, addressState) {
                          return CartSummaryBar(
                            label: 'Total',
                            showBasket: false,
                            amount: cart.isEmpty ? 0 : BookingPricing.total(cart.totalPrice),
                            buttonText: 'Pesan',
                            isLoading: booking.isSubmitting,
                            onPressed: cart.isEmpty
                                ? null
                                : () => context.read<BookingCubit>().submit(
                                      cart: cart,
                                      address: addressState.selectedAddress,
                                    ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderDetail(BuildContext context, CartState cart) {
    return DetailInfoCard(
      title: 'Detail Pesanan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  cart.shop?.name ?? '-',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.pop(),
                child: const Text(
                  'Tambah jasa',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (cart.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Belum ada layanan yang dipilih.',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            )
          else
            ...cart.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CartItemRow(item: item, photoUrl: cart.shop?.photoUrl),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userName = authState is AuthSuccess ? authState.user.fullName : '';

        return BlocBuilder<AddressCubit, AddressState>(
          builder: (context, state) {
            final CustomerAddress? address = state.selectedAddress;
            final isLoading = state.status == AddressStatus.loading;

            final contact = [
              if (userName.isNotEmpty) userName,
              if (address?.phone != null && address!.phone!.isNotEmpty) '(${address.phone})',
            ].join(' ');

            return InkWell(
              onTap: () => context.push('/customer/address', extra: true),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Color(0xFF111827), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: isLoading && address == null
                          ? const Text(
                              'Memuat alamat...',
                              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  address?.fullAddress ?? 'Pilih alamat',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  address == null
                                      ? 'Alamat wajib diisi sebelum memesan'
                                      : (contact.isEmpty ? address.label : contact),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: address == null
                                        ? AppColors.danger
                                        : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF111827)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItem item;
  final String? photoUrl;

  const _CartItemRow({required this.item, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final cartCubit = context.read<CartCubit>();
    final service = item.service;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ServiceThumbnail(
          categoryName: service.categoryName,
          imageUrl: service.photoUrl ?? photoUrl,
          width: 68,
          height: 68,
          iconSize: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                service.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 6),
              Text(
                CurrencyFormatter.format(service.price),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () => cartCubit.remove(service.id),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.danger),
              ),
            ),
            const SizedBox(height: 14),
            QuantityStepper(
              value: item.quantity,
              min: 1,
              onChanged: (value) => cartCubit.updateQuantity(service.id, value),
            ),
          ],
        ),
      ],
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final PaymentMethod method;
  final VoidCallback onTap;

  const _PaymentTile({required this.method, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Metode Pembayaran',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method.label,
                    style: const TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF111827)),
          ],
        ),
      ),
    );
  }
}
