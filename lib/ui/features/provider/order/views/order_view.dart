import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servis_ku/core/widgets/order_card.dart';
import '../bloc/order_cubit.dart';
import '../bloc/order_detail_cubit.dart';
import '../bloc/order_state.dart';
import '../domain/order_entity.dart';
import '../domain/order_status.dart';
import 'order_detail_view.dart';

class OrderView extends StatelessWidget {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _OrderViewBody();
  }
}

class _OrderViewBody extends StatefulWidget {
  const _OrderViewBody();

  @override
  State<_OrderViewBody> createState() => _OrderViewBodyState();
}

class _OrderViewBodyState extends State<_OrderViewBody> {
  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().loadOrders();
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
              context.read<OrderCubit>().rejectOrder(order.id, reasonController.text);
            },
            child: const Text('Tolak Order', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getEmptyMessage(OrderFilter filter) {
    switch (filter) {
      case OrderFilter.semua:
        return 'Belum ada order';
      case OrderFilter.baru:
        return 'Belum ada order baru';
      case OrderFilter.aktif:
        return 'Tidak ada order yang sedang berjalan';
      case OrderFilter.selesai:
        return 'Belum ada order selesai';
      case OrderFilter.dibatalkan:
        return 'Tidak ada order dibatalkan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: BlocConsumer<OrderCubit, OrderState>(
          listener: (context, state) {
            if (state is OrderLoaded && state.snackbarMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.snackbarMessage!),
                  duration: const Duration(seconds: 3),
                ),
              );
              context.read<OrderCubit>().clearSnackbar();
            }
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Text(
                    'Order',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),

                // Filter Tabs
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: OrderFilter.values.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = OrderFilter.values[index];
                      final currentFilter = state is OrderLoaded
                          ? state.selectedFilter
                          : OrderFilter.semua;
                      final bool isActive = filter == currentFilter;

                      return _FilterChip(
                        label: filter.label,
                        isActive: isActive,
                        onTap: () => context.read<OrderCubit>().setFilter(filter),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Body List
                Expanded(
                  child: _buildListContent(context, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildListContent(BuildContext context, OrderState state) {
    if (state is OrderLoading || state is OrderInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is OrderFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.message,
              style: const TextStyle(color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<OrderCubit>().loadOrders(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (state is OrderLoaded) {
      final orders = state.filteredOrders;
      if (orders.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => context.read<OrderCubit>().loadOrders(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/cardbox.png',
                      width: 120,
                      height: 120,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.inbox_outlined,
                        size: 72,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getEmptyMessage(state.selectedFilter),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => context.read<OrderCubit>().loadOrders(),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          itemCount: orders.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final order = orders[index];
            final isLoading = state.actionInProgressId == order.id;

            return OrderCard(
              order: order,
              isActionLoading: isLoading,
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
                  // Refresh on return to ensure sync
                  context.read<OrderCubit>().loadOrders();
                });
              },
              onReject: order.status == OrderStatus.pending
                  ? () => _showRejectDialog(context, order)
                  : null,
              onAccept: order.status == OrderStatus.pending
                  ? () => context.read<OrderCubit>().acceptOrder(order.id)
                  : null,
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1D56CF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF1D56CF) : const Color(0xFFE5E7EB),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
