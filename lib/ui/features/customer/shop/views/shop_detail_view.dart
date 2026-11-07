import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_ku/core/theme/app_colors.dart';
import 'package:servis_ku/core/utils/currency_formatter.dart';
import 'package:servis_ku/ui/features/customer/shop/bloc/cart_cubit.dart';
import 'package:servis_ku/ui/features/customer/shop/bloc/cart_state.dart';
import 'package:servis_ku/ui/features/customer/shop/bloc/shop_detail_cubit.dart';
import 'package:servis_ku/ui/features/customer/shop/bloc/shop_detail_state.dart';
import 'package:servis_ku/ui/features/customer/shop/domain/shop_service.dart';
import 'package:servis_ku/ui/features/customer/shop/domain/shop_summary.dart';
import 'package:servis_ku/ui/features/customer/shop/views/service_order_sheets.dart';
import 'package:servis_ku/ui/features/customer/widgets/cart_summary_bar.dart';
import 'package:servis_ku/ui/features/customer/widgets/customer_confirm_dialog.dart';
import 'package:servis_ku/ui/features/customer/widgets/customer_page_header.dart';
import 'package:servis_ku/ui/features/customer/widgets/service_thumbnail.dart';
import 'package:servis_ku/ui/features/customer/widgets/shop_info_card.dart';

class ShopDetailView extends StatelessWidget {
  const ShopDetailView({super.key});

  static const double _heroHeight = 240;
  static const double _cardOverlap = 64;

  Future<void> _onServiceTap(
    BuildContext context,
    ShopSummary shop,
    ShopService service,
  ) async {
    final cartCubit = context.read<CartCubit>();
    final currentQuantity = cartCubit.state.belongsTo(shop.id)
        ? cartCubit.state.quantityOf(service.id)
        : 0;

    final quantity = await showServiceQuantitySheet(
      context,
      service: service,
      initialQuantity: currentQuantity > 0 ? currentQuantity : 1,
    );

    if (quantity == null || !context.mounted) return;

    if (quantity > 0 && cartCubit.isFromAnotherShop(shop.id)) {
      final previousShop = cartCubit.state.shop?.name ?? 'penyedia jasa lain';
      final replace = await showCustomerConfirmDialog(
        context,
        title: 'Ganti pesanan?',
        message: 'Pesanan dari $previousShop akan dihapus dan diganti dengan pesanan baru.',
        cancelText: 'Batal',
        confirmText: 'Ganti',
        isDanger: false,
      );
      if (!replace) return;
    }

    cartCubit.setQuantity(shop: shop, service: service, quantity: quantity);
  }

  void _checkout(BuildContext context) {
    context.push('/customer/checkout');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopDetailCubit, ShopDetailState>(
      builder: (context, state) {
        final shop = state.shop;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context.read<ShopDetailCubit>().load(),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(child: _buildHero(context, state)),
                      ..._buildBody(context, state),
                    ],
                  ),
                ),
              ),
              if (shop != null)
                BlocBuilder<CartCubit, CartState>(
                  builder: (context, cart) {
                    if (!cart.belongsTo(shop.id)) return const SizedBox.shrink();
                    return CartSummaryBar(
                      amount: cart.totalPrice,
                      buttonText: 'Checkout',
                      badgeCount: cart.totalQuantity,
                      onBasketTap: () => showCartSheet(
                        context,
                        canCheckout: shop.isOnline,
                        onCheckout: () => _checkout(context),
                      ),
                      onPressed: shop.isOnline ? () => _checkout(context) : null,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHero(BuildContext context, ShopDetailState state) {
    final shop = state.shop;
    final topPadding = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: _heroHeight + _cardOverlap + topPadding,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _heroHeight + topPadding,
            child: ServiceThumbnail(
              categoryName: shop?.categoryName,
              imageUrl: shop?.photoUrl,
              borderRadius: 0,
              iconSize: 80,
            ),
          ),
          Positioned(
            top: topPadding + 12,
            left: 16,
            child: const CustomerBackButton(
              backgroundColor: Colors.white,
              iconColor: Color(0xFF111827),
            ),
          ),
          if (shop != null)
            Positioned(
              left: 20,
              right: 20,
              bottom: 0,
              child: ShopInfoCard(
                shop: shop,
                rating: state.rating,
                onTap: () => context.push(
                  '/customer/shop/${shop.id}/reviews',
                  extra: shop,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildBody(BuildContext context, ShopDetailState state) {
    final shop = state.shop;

    if (state.status == ShopDetailStatus.loading && state.services.isEmpty) {
      return const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ];
    }

    if (state.status == ShopDetailStatus.failure || shop == null) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Text(
                  state.errorMessage ?? 'Gagal memuat penyedia jasa.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.read<ShopDetailCubit>().load(),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Layanan tersedia',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              if (!shop.isOnline) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFB45309)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Penyedia jasa sedang offline. Pesanan belum bisa diproses saat ini.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      if (state.services.isEmpty)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'Belum ada layanan aktif.',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          sliver: BlocBuilder<CartCubit, CartState>(
            builder: (context, cart) {
              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 204,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final service = state.services[index];
                    final quantity =
                        cart.belongsTo(shop.id) ? cart.quantityOf(service.id) : 0;
                    return _ServiceCard(
                      service: service,
                      photoUrl: shop.photoUrl,
                      quantity: quantity,
                      onTap: () => _onServiceTap(context, shop, service),
                    );
                  },
                  childCount: state.services.length,
                ),
              );
            },
          ),
        ),
    ];
  }
}

class _ServiceCard extends StatelessWidget {
  final ShopService service;
  final String? photoUrl;
  final int quantity;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.photoUrl,
    required this.quantity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = quantity > 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ServiceThumbnail(
                      categoryName: service.categoryName,
                      imageUrl: service.photoUrl ?? photoUrl,
                    ),
                    if (isSelected)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'x$quantity',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
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
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        CurrencyFormatter.format(service.price),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
