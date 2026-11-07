import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_ku/core/theme/app_colors.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';
import 'package:servis_ku/core/widgets/detail_info_card.dart';
import 'package:servis_ku/core/widgets/status_timeline.dart';
import 'package:servis_ku/ui/features/customer/order/bloc/customer_order_cubit.dart';
import 'package:servis_ku/ui/features/customer/order/bloc/customer_order_detail_cubit.dart';
import 'package:servis_ku/ui/features/customer/order/bloc/customer_order_detail_state.dart';
import 'package:servis_ku/ui/features/customer/order/domain/customer_order.dart';
import 'package:servis_ku/ui/features/customer/widgets/customer_confirm_dialog.dart';
import 'package:servis_ku/ui/features/customer/widgets/customer_page_header.dart';
import 'package:servis_ku/ui/features/customer/widgets/order_status_badge.dart';
import 'package:servis_ku/ui/features/customer/widgets/price_summary.dart';
import 'package:servis_ku/ui/features/customer/widgets/rating_stars.dart';
import 'package:servis_ku/ui/features/customer/widgets/service_thumbnail.dart';
import 'package:servis_ku/ui/features/provider/order/domain/order_helper.dart';
import 'package:servis_ku/ui/features/provider/order/domain/order_status.dart';

class CustomerOrderDetailView extends StatelessWidget {
  const CustomerOrderDetailView({super.key});

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await showCustomerConfirmDialog(
      context,
      title: 'Yakin ingin membatalkan pesanan?',
      message: 'Tindakan ini tidak dapat dikembalikan',
    );
    if (confirmed && context.mounted) {
      context.read<CustomerOrderDetailCubit>().cancelOrder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerOrderDetailCubit, CustomerOrderDetailState>(
      listenWhen: (prev, curr) =>
          prev.successMessage != curr.successMessage ||
          prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        if (state.successMessage != null) {
          _showMessage(context, state.successMessage!);
          context.read<CustomerOrderCubit>().loadOrders();
        } else if (state.errorMessage != null && state.order != null) {
          _showMessage(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        final order = state.order;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const CustomerPageHeader(title: 'Detail Order'),
                Expanded(child: _buildBody(context, state)),
                if (order != null) _buildBottomAction(context, order, state.isActionInProgress),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CustomerOrderDetailState state) {
    final order = state.order;

    if (order == null && state.status == OrderDetailStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (order == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.errorMessage ?? 'Gagal memuat detail pesanan.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.read<CustomerOrderDetailCubit>().load(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final note = order.note?.trim();
    final reason = order.reason?.trim();

    return RefreshIndicator(
      onRefresh: () => context.read<CustomerOrderDetailCubit>().load(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.displayNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                OrderStatusBadge(status: order.status),
              ],
            ),
            if (order.status == OrderStatus.pending) ...[
              const SizedBox(height: 12),
              _buildWaitingBanner(order),
            ],
            const SizedBox(height: 14),
            const Text(
              'Alamat Kamu',
              style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.address,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF111827),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProviderCard(context, order),
            const SizedBox(height: 12),
            DetailInfoCard(
              title: 'Detail Harga',
              child: PriceSummary(
                lines: order.priceLines,
                serviceFee: order.serviceFee,
              ),
            ),
            if (note != null && note.isNotEmpty) ...[
              const SizedBox(height: 12),
              DetailInfoCard(
                title: 'Catatan Kamu',
                child: Text(
                  note,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                    height: 1.4,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            DetailInfoCard(
              title: 'Riwayat Status',
              child: StatusTimeline(items: OrderHelper.buildTimeline(order.order)),
            ),
            if (order.isRated) ...[
              const SizedBox(height: 12),
              _buildRatingCard(order),
            ],
            if (order.isCancelled && reason != null && reason.isNotEmpty) ...[
              const SizedBox(height: 12),
              DetailInfoCard(
                title: 'Alasan Pembatalan',
                child: Text(
                  reason,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingBanner(CustomerOrder order) {
    final timeText = order.responseTimeLeft > Duration.zero
        ? 'Penyedia jasa punya waktu sekitar ${order.responseTimeLeftLabel} untuk merespons. Jika tidak ada respons, pesanan dibatalkan otomatis.'
        : 'Batas waktu respons sudah habis, pesanan akan segera dibatalkan otomatis.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Menunggu konfirmasi penyedia jasa',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeText,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context, CustomerOrder order) {
    return DetailInfoCard(
      title: 'Info Penyedia Jasa',
      child: Row(
        children: [
          ServiceThumbnail(
            imageUrl: order.shopPhotoUrl,
            width: 36,
            height: 36,
            borderRadius: 18,
            iconSize: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              order.shopName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ),
          _circleIconButton(
            Icons.call_outlined,
            () => _showMessage(context, 'Fitur panggilan segera hadir'),
          ),
          const SizedBox(width: 8),
          _circleIconButton(
            Icons.chat_bubble_outline,
            () => _showMessage(context, 'Fitur chat segera hadir'),
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: Color(0xFFEFF6FF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }

  Widget _buildRatingCard(CustomerOrder order) {
    final review = order.review?.trim();

    return DetailInfoCard(
      title: 'Rating Kamu',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RatingStars(
                rating: (order.rating ?? 0).toDouble(),
                size: 22,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Text(
                (order.rating ?? 0).toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          if (review != null && review.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF374151),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomAction(
    BuildContext context,
    CustomerOrder order,
    bool isActionInProgress,
  ) {
    final Widget button;

    if (order.canCancel) {
      button = CustomButton(
        text: 'Batalkan Pesanan',
        type: ButtonType.danger,
        isLoading: isActionInProgress,
        onPressed: isActionInProgress ? null : () => _confirmCancel(context),
      );
    } else if (order.status == OrderStatus.accepted ||
        order.status == OrderStatus.inProgress) {
      button = CustomButton(
        text: 'Batalkan Pesanan',
        type: ButtonType.custom,
        customColor: const Color(0xFFF7A8A8),
        customTextColor: Colors.white,
        onPressed: () => _showMessage(
          context,
          'Pesanan sudah diterima penyedia jasa dan tidak dapat dibatalkan.',
        ),
      );
    } else if (order.needsReview) {
      button = CustomButton(
        text: 'Konfirmasi Selesai',
        onPressed: () => context.push(
          '/customer/order/${order.id}/review',
          extra: context.read<CustomerOrderDetailCubit>(),
        ),
      );
    } else {
      button = CustomButton(
        text: 'Kembali ke Beranda',
        variant: ButtonVariant.outlined,
        onPressed: () => context.go('/customer/home'),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SafeArea(top: false, child: button),
    );
  }
}
