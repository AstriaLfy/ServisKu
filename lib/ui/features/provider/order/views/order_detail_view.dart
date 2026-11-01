import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servis_ku/core/theme/app_colors.dart';
import 'package:servis_ku/core/utils/currency_formatter.dart';
import 'package:servis_ku/core/widgets/custom_button.dart';
import 'package:servis_ku/core/widgets/detail_info_card.dart';
import 'package:servis_ku/core/widgets/status_timeline.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/order_detail_cubit.dart';
import '../bloc/order_detail_state.dart';
import '../domain/order_entity.dart';
import '../domain/order_helper.dart';
import '../domain/order_status.dart';

class OrderDetailView extends StatefulWidget {
  final OrderEntity order;

  const OrderDetailView({super.key, required this.order});

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  @override
  void initState() {
    super.initState();
    context.read<OrderDetailCubit>().loadOrderDetail(widget.order.id);
  }

  Future<void> _makePhoneCall(String? phone) async {
    if (phone == null || phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor telepon tidak tersedia')),
      );
      return;
    }

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phone.replaceAll(RegExp(r'\s+'), ''),
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka aplikasi telepon')),
        );
      }
    }
  }

  void _showChatPlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur chat segera hadir')),
    );
  }

  void _showRejectDialog(BuildContext context, OrderDetailCubit cubit) {
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
              cubit.rejectOrder(reasonController.text);
            },
            child: const Text('Tolak Order', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(BuildContext context, OrderDetailCubit cubit) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Selesaikan Order'),
        content: const Text(
          'Pastikan pekerjaan telah selesai dilakukan sebelum menyelesaikan order.',
          style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              cubit.completeOrder();
            },
            child: const Text('Ya, Selesaikan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderDetailCubit, OrderDetailState>(
      listener: (context, state) {
        if (state is OrderDetailLoaded) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        }
      },
      builder: (context, state) {
        final order = state is OrderDetailLoaded ? state.order : widget.order;
        final isActionInProgress = state is OrderDetailLoaded && state.isActionInProgress;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(context, order),
                Expanded(
                  child: state is OrderDetailLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoPelanggan(order),
                              const SizedBox(height: 16),
                              _buildInfoJasa(order),
                              if (order.customerNote != null &&
                                  order.customerNote!.isNotEmpty) ...[
                                const SizedBox(height: 16),
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
                              ],
                              const SizedBox(height: 16),
                              _buildHargaEstimasi(order),
                              const SizedBox(height: 16),
                              DetailInfoCard(
                                title: 'Riwayat Status',
                                child: StatusTimeline(
                                  items: OrderHelper.buildTimeline(order),
                                ),
                              ),
                              if (order.status == OrderStatus.completed &&
                                  order.rating != null) ...[
                                const SizedBox(height: 16),
                                _buildRatingCard(order),
                              ],
                              if ((order.status == OrderStatus.rejected ||
                                      order.status == OrderStatus.cancelled) &&
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
                _buildBottomActions(context, order, isActionInProgress),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, OrderEntity order) {
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
                '#${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
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

  Widget _buildInfoPelanggan(OrderEntity order) {
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
                Text(
                  order.customerPhone ?? '-',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          _circleIconButton(
            Icons.call_outlined,
            () => _makePhoneCall(order.customerPhone),
          ),
          const SizedBox(width: 8),
          _circleIconButton(
            Icons.chat_bubble_outline,
            _showChatPlaceholder,
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

  Widget _buildInfoJasa(OrderEntity order) {
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
          if (order.customerAddress != null && order.customerAddress!.isNotEmpty) ...[
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
                    order.customerAddress!,
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
          if (order.items.isNotEmpty) ...[
            const Divider(height: 20, color: Color(0xFFE5E7EB)),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.serviceName} x${item.quantity}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
                    ),
                    Text(
                      CurrencyFormatter.format(item.totalPrice),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHargaEstimasi(OrderEntity order) {
    return DetailInfoCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            order.totalPrice != null ? 'Total Harga' : 'Harga Estimasi',
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          Text(
            CurrencyFormatter.format(order.effectivePrice),
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

  Widget _buildRatingCard(OrderEntity order) {
    return DetailInfoCard(
      title: 'Rating dari Pelanggan',
      child: Row(
        children: [
          ...List.generate(5, (index) {
            final filled = index < (order.rating ?? 0).round();
            return Icon(
              filled ? Icons.star_rounded : Icons.star_border_rounded,
              size: 20,
              color: const Color(0xFFFBBF24),
            );
          }),
          const SizedBox(width: 8),
          Text(
            order.rating!.toStringAsFixed(1),
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

  Widget _buildBottomActions(
      BuildContext context, OrderEntity order, bool isActionInProgress) {
    final cubit = context.read<OrderDetailCubit>();

    if (order.status == OrderStatus.completed) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: SafeArea(
          top: false,
          child: CustomButton(
            text: 'Kembali',
            height: 46,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );
    }

    if (order.status == OrderStatus.rejected ||
        order.status == OrderStatus.cancelled) {
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
        child: order.status == OrderStatus.pending
            ? Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Tolak',
                      variant: ButtonVariant.outlined,
                      height: 46,
                      onPressed: isActionInProgress
                          ? null
                          : () => _showRejectDialog(context, cubit),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Terima Order',
                      height: 46,
                      isLoading: isActionInProgress,
                      onPressed: isActionInProgress
                          ? null
                          : () => cubit.acceptOrder(),
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
                      onPressed: _showChatPlaceholder,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Selesaikan Order',
                      height: 46,
                      isLoading: isActionInProgress,
                      onPressed: isActionInProgress
                          ? null
                          : () => _showCompleteDialog(context, cubit),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
