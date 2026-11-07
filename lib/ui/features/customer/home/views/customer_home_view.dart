import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_ku/core/theme/app_colors.dart';
import 'package:servis_ku/ui/features/auth/bloc/auth_bloc.dart';
import 'package:servis_ku/ui/features/customer/home/bloc/customer_home_cubit.dart';
import 'package:servis_ku/ui/features/customer/home/bloc/customer_home_state.dart';
import 'package:servis_ku/ui/features/customer/order/bloc/customer_order_cubit.dart';
import 'package:servis_ku/ui/features/customer/order/bloc/customer_order_state.dart';
import 'package:servis_ku/ui/features/customer/profile/bloc/customer_profile_cubit.dart';
import 'package:servis_ku/ui/features/customer/shop/domain/shop_summary.dart';
import 'package:servis_ku/ui/features/customer/widgets/category_visual.dart';
import 'package:servis_ku/ui/features/customer/widgets/customer_avatar.dart';
import 'package:servis_ku/ui/features/customer/widgets/order_summary_card.dart';
import 'package:servis_ku/ui/features/customer/widgets/service_thumbnail.dart';
import 'package:servis_ku/ui/features/provider/services/domain/service_item.dart';

class CustomerHomeView extends StatefulWidget {
  const CustomerHomeView({super.key});

  @override
  State<CustomerHomeView> createState() => _CustomerHomeViewState();
}

class _CustomerHomeViewState extends State<CustomerHomeView> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerHomeCubit>().load();
    context.read<CustomerOrderCubit>().loadOrders();
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<CustomerHomeCubit>().load(),
      context.read<CustomerOrderCubit>().loadOrders(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: const [
              _HomeHeader(),
              SizedBox(height: 16),
              _PromoBanner(),
              SizedBox(height: 20),
              _CategorySection(),
              _ActiveOrderSection(),
              SizedBox(height: 24),
              _RecommendationSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthSuccess ? state.user : null;
        final name = user != null && user.fullName.isNotEmpty ? user.fullName : 'Pelanggan';
        final avatarUrl = context.select<CustomerProfileCubit, String?>(
          (cubit) => cubit.state.profile.avatarUrl,
        );

        return Row(
          children: [
            CustomerAvatar(radius: 20, imageUrl: avatarUrl),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const Text(
                    'Customer',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 96),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF1D56CF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 52,
            bottom: 0,
            child: SvgPicture.asset(
              'assets/images/banner_shape.svg',
              width: 92,
              height: 68,
            ),
          ),
          Positioned(
            right: 16,
            bottom: 3,
            child: Image.asset(
              'assets/images/banner_truck.png',
              width: 116,
              height: 90,
              fit: BoxFit.contain,
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(29, 16, 140, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kania Travel & Logistics',
                  style: TextStyle(fontSize: 11, color: Colors.white),
                ),
                SizedBox(height: 2),
                Text(
                  'Jasa Titip & Pengiriman',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'see more →',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerHomeCubit, CustomerHomeState>(
      buildWhen: (prev, curr) =>
          prev.status != curr.status ||
          prev.categories != curr.categories ||
          prev.selectedCategoryId != curr.selectedCategoryId,
      builder: (context, state) {
        if (state.status == CustomerHomeStatus.loading ||
            state.status == CustomerHomeStatus.initial) {
          return SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) => Container(
                width: 85,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        }

        if (state.categories.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: state.categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = state.categories[index];
              return _CategoryItem(
                category: category,
                isSelected: state.selectedCategoryId == category.id,
                onTap: () =>
                    context.read<CustomerHomeCubit>().selectCategory(category.id),
              );
            },
          ),
        );
      },
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final ServiceCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 85,
        padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: CategoryIcon(categoryName: category.name, size: 64)),
            const SizedBox(height: 2),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.primary : const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveOrderSection extends StatelessWidget {
  const _ActiveOrderSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerOrderCubit, CustomerOrderState>(
      builder: (context, state) {
        final activeOrders = state.activeOrders;
        if (activeOrders.isEmpty) return const SizedBox.shrink();

        final order = activeOrders.first;

        return Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Dalam Proses',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  if (activeOrders.length > 1)
                    GestureDetector(
                      onTap: () => context.go('/customer/riwayat'),
                      child: Text(
                        'Lihat semua (${activeOrders.length})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              OrderSummaryCard(
                title: order.displayNumber,
                order: order,
                onTap: () => context.push('/customer/order/${order.id}'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecommendationSection extends StatelessWidget {
  const _RecommendationSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerHomeCubit, CustomerHomeState>(
      builder: (context, state) {
        final selectedCategory = state.categories
            .where((c) => c.id == state.selectedCategoryId)
            .firstOrNull;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedCategory == null
                  ? 'Rekomendasi Jasa'
                  : 'Jasa ${selectedCategory.name}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            _buildContent(context, state),
          ],
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, CustomerHomeState state) {
    if (state.status == CustomerHomeStatus.initial ||
        state.status == CustomerHomeStatus.loading ||
        state.isLoadingShops) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == CustomerHomeStatus.failure) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Text(
              state.errorMessage ?? 'Gagal memuat data.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.read<CustomerHomeCubit>().load(),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    if (state.shops.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'Belum ada penyedia jasa yang tersedia.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: state.shops.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 196,
      ),
      itemBuilder: (context, index) {
        final shop = state.shops[index];
        return _ShopCard(
          shop: shop,
          onTap: () => context.push('/customer/shop/${shop.id}', extra: shop),
        );
      },
    );
  }
}

class _ShopCard extends StatelessWidget {
  final ShopSummary shop;
  final VoidCallback onTap;

  const _ShopCard({required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ServiceThumbnail(
                      categoryName: shop.categoryName,
                      imageUrl: shop.photoUrl,
                    ),
                    if (!shop.isOnline)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Offline',
                            style: TextStyle(fontSize: 10, color: Colors.white),
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            shop.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        if (shop.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      shop.categoryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFBBF24)),
                        const SizedBox(width: 4),
                        Text(
                          shop.rating.hasRating ? shop.rating.averageLabel : 'Baru',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
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
