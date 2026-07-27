import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servis_ku/core/theme/app_colors.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';
import 'package:servis_ku/core/widgets/detail_info_card.dart';
import 'package:servis_ku/core/widgets/status_timeline.dart';
import 'package:servis_ku/data/models/order_model.dart';
import 'package:servis_ku/ui/features/provider/order/bloc/order_cubit.dart';

class OrderDetailView extends StatelessWidget {
  final OrderModel order;

  const OrderDetailView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoPelanggan(),
                    const SizedBox(height: 16),
                    _buildInfoJasa(),
                    const SizedBox(height: 16),
                    if (order.customerNote != null &&
                        order.customerNote!.isNotEmpty) ...[
                      DetailInfoCard(
                        title: 'Catatan Pelanggan',
                        child: Text(
                          order.customerNote!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF374151),
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildHargaEstimasi(),
                    const SizedBox(height: 16),
                    DetailInfoCard(
                      title: 'Riwayat Status',
                      child: StatusTimeline(items: order.statusHistory),
                    ),
                    if (order.status == OrderStatus.selesai &&
                        order.orderRating != null) ...[
                      const SizedBox(height: 16),
                      _buildRatingCard(),
                    ],
                    if (order.status == OrderStatus.dibatalkan &&
                        order.cancellationReason != null) ...[
                      const SizedBox(height: 16),
                      DetailInfoCard(
                        title: 'Alasan Pembatalan',
                        child: Text(
                          order.cancellationReason!,
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
            ),
            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Detail Order',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '#${order.id}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: order.status.bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  order.status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: order.status.textColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPelanggan() {
    return DetailInfoCard(
      title: 'Info Pelanggan',
      child: Row(
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFFBBF24),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${order.customerRating} (${order.customerRatingCount} ulasan)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _circleIconButton(Icons.call_outlined, () {}),
          const SizedBox(width: 8),
          _circleIconButton(Icons.chat_bubble_outline, () {}),
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

  Widget _buildInfoJasa() {
    return DetailInfoCard(
      title: 'Info Jasa',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.work_outline,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.serviceName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.serviceAddress,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHargaEstimasi() {
    return DetailInfoCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Harga Estimasi',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          Text(
            order.price,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard() {
    return DetailInfoCard(
      title: 'Rating dari Pelanggan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(5, (index) {
                final filled = index < (order.orderRating ?? 0).round();
                return Icon(
                  filled ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 20,
                  color: const Color(0xFFFBBF24),
                );
              }),
              const SizedBox(width: 8),
              Text(
                order.orderRating!.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          if (order.reviewText != null && order.reviewText!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              order.reviewText!,
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

  Widget _buildBottomActions(BuildContext context) {
    // Selesai & Dibatalkan gak butuh tombol aksi apa-apa
    if (order.status == OrderStatus.selesai ||
        order.status == OrderStatus.dibatalkan) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SafeArea(
        top: false,
        child: order.status == OrderStatus.baru
            ? Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Tolak',
                      variant: ButtonVariant.outlined,
                      height: 46,
                      onPressed: () {
                        context.read<OrderCubit>().rejectOrder(order.id);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Terima',
                      height: 46,
                      onPressed: () {
                        context.read<OrderCubit>().acceptOrder(order.id);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Chat Pelanggan',
                      variant: ButtonVariant.outlined,
                      height: 46,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Selesaikan Order',
                      height: 46,
                      onPressed: () {
                        context.read<OrderCubit>().completeOrder(order.id);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
