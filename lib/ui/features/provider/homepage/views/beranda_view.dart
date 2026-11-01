import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '/core/theme/app_colors.dart';
import '/core/utils/currency_formatter.dart';
import '/core/widgets/custom_button.dart';
import '../../../../features/auth/bloc/auth_bloc.dart';
import '../../order/bloc/order_detail_cubit.dart';
import '../../order/domain/order_entity.dart';
import '../../order/domain/order_helper.dart';
import '../../order/views/order_detail_view.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';
import '../domain/home_helper.dart';
import '../domain/shop_status.dart';

class BerandaView extends StatefulWidget {
  const BerandaView({super.key});

  @override
  State<BerandaView> createState() => _BerandaViewState();
}

class _BerandaViewState extends State<BerandaView> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().load();
  }

  void _showRejectDialog(BuildContext context, OrderEntity order) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tolak Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan alasan penolakan (opsional):',
              style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: Sedang penuh, di luar jangkauan...',
                hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<HomeCubit>().rejectOrder(order.id, reasonController.text);
            },
            child: const Text('Tolak Order', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<HomeCubit, HomeState>(
          listener: (context, state) {
            if (state is HomeLoaded && state.snackbarMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.snackbarMessage!),
                  duration: const Duration(seconds: 3),
                ),
              );
              context.read<HomeCubit>().clearSnackbar();
            }
          },
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HomeFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<HomeCubit>().load(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final loaded = state as HomeLoaded;
            return RefreshIndicator(
              onRefresh: () => context.read<HomeCubit>().refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(loaded),
                    if (!loaded.isVerified) ...[
                      const SizedBox(height: 16),
                      _buildUnverifiedBanner(),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      'Ringkasan Hari ini',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCards(loaded),
                    const SizedBox(height: 24),
                    _buildOrderMasukHeader(loaded),
                    const SizedBox(height: 12),
                    _buildOrderSection(loaded),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUnverifiedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, color: Color(0xFFD97706), size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Akun Anda sedang menunggu verifikasi, belum bisa menerima order.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF92400E),
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(HomeLoaded state) {
    final photoUrl = state.shopStatus.photoUrl;
    final isOnline = state.isOnline;
    final isToggling = state.isTogglingOnline;
    final isVerified = state.isVerified;

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey[300],
          backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
              ? NetworkImage(photoUrl)
              : null,
          child: (photoUrl == null || photoUrl.isEmpty)
              ? const Icon(Icons.person, color: Colors.white, size: 26)
              : null,
        ),
        const SizedBox(width: 12),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final name = (authState is AuthSuccess && authState.user.fullName.isNotEmpty)
                ? authState.user.fullName
                : state.shopStatus.name;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $name',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Mitra Profesional',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            );
          },
        ),
        const Spacer(),

        // Online/Offline Toggle
        GestureDetector(
          onTap: (isToggling || !isVerified)
              ? null
              : () => context.read<HomeCubit>().toggleOnline(!isOnline),
          child: Opacity(
            opacity: (!isVerified || isToggling) ? 0.6 : 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isOnline
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF9CA3AF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isOnline
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 8),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 20,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: isOnline
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFE5E7EB),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: isOnline
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(HomeLoaded state) {
    final summary = state.summary;
    final revComp = HomeHelper.calculateRevenueComparison(
      today: summary.revenueToday,
      yesterday: summary.revenueYesterday,
    );
    final ratingInfo = HomeHelper.calculateRatingInfo(
      ratingAvg: summary.ratingAvg,
      ratingCount: summary.ratingCount,
    );

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            assetPath: 'assets/icons/wallet_icon.png',
            title: 'Pendapatan Hari ini',
            value: CurrencyFormatter.format(summary.revenueToday),
            subtext: revComp.text,
            subtextIcon: revComp.icon ?? Icons.trending_flat,
            subtextColor: revComp.color,
          ),
        ),
        const SizedBox(width: 8),

        Expanded(
          child: _buildSummaryCard(
            assetPath: 'assets/images/clipboard.png',
            title: 'Jumlah Order',
            value: summary.ordersToday.toString(),
            subtext: '${summary.completedToday} selesai',
            subtextIcon: Icons.check_circle,
            subtextColor: const Color(0xFF22C55E),
          ),
        ),
        const SizedBox(width: 8),

        Expanded(
          child: _buildSummaryCard(
            assetPath: 'assets/images/rating.png',
            title: 'Rating',
            value: ratingInfo.ratingText,
            subtext: ratingInfo.label,
            subtextIcon: Icons.star,
            subtextColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String assetPath,
    required String title,
    required String value,
    required String subtext,
    required IconData subtextIcon,
    required Color subtextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(assetPath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 8),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              Icon(subtextIcon, size: 12, color: subtextColor),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  subtext,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    color: subtextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderMasukHeader(HomeLoaded state) {
    final count = state.incomingOrders.length;
    final showBadge = state.isOnline && state.isVerified && count > 0;

    return Row(
      children: [
        const Text(
          'Order Masuk',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        if (showBadge) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count Baru',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
        const Spacer(),

        GestureDetector(
          onTap: () {
            context.go('/provider/order');
          },
          child: const Text(
            'Lihat Semua',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSection(HomeLoaded state) {
    if (!state.isVerified) {
      return _buildEmptyOrderState(
        subtitle: 'Akun belum diverifikasi untuk menerima order baru',
      );
    }

    if (!state.isOnline) {
      return _buildEmptyOrderState(
        subtitle: 'Aktifkan status Online untuk menerima order',
      );
    }

    final orders = state.incomingOrders;
    if (orders.isEmpty) {
      return _buildEmptyOrderState(
        subtitle: 'Order baru akan muncul di sini ketika ada yang membutuhkan jasa anda',
      );
    }

    return Column(
      children: orders.map((order) {
        final isLoading = state.actionInProgressId == order.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildOrderCard(
            order: order,
            isLoading: isLoading,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => OrderDetailCubit(),
                    child: OrderDetailView(order: order),
                  ),
                ),
              ).then((_) {
                context.read<HomeCubit>().refresh();
              });
            },
            onReject: () => _showRejectDialog(context, order),
            onAccept: () => context.read<HomeCubit>().acceptOrder(order.id),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyOrderState({required String subtitle}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/cardbox.png',
            height: 150,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum ada order hari ini',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard({
    required OrderEntity order,
    required bool isLoading,
    required VoidCallback onTap,
    required VoidCallback onReject,
    required VoidCallback onAccept,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.serviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Baru',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      OrderHelper.formatRelativeTime(order.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildInfoTile(
                    iconWidget: const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    value: order.distanceKm != null ? '${order.distanceKm} km' : '-',
                    label: 'Jarak',
                  ),
                ),
                Expanded(
                  child: _buildInfoTile(
                    iconWidget: Image.asset(
                      'assets/icons/wallet_icon.png',
                      width: 14,
                      height: 14,
                    ),
                    value: CurrencyFormatter.format(order.estimatedPrice),
                    label: 'Estimasi Harga',
                  ),
                ),
                Expanded(
                  child: _buildInfoTile(
                    iconWidget: const Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    value: order.estimatedMinutes != null
                        ? '${order.estimatedMinutes} menit'
                        : '-',
                    label: 'Estimasi Waktu',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Tolak',
                    variant: ButtonVariant.outlined,
                    height: 42,
                    borderRadius: 24,
                    onPressed: isLoading ? null : onReject,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Terima',
                    height: 42,
                    borderRadius: 24,
                    isLoading: isLoading,
                    onPressed: isLoading ? null : onAccept,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required Widget iconWidget,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          child: Center(child: iconWidget),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
