import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_ku/ui/features/customer/order/bloc/customer_order_cubit.dart';
import 'package:servis_ku/ui/features/customer/order/bloc/customer_order_state.dart';
import 'package:servis_ku/ui/features/customer/order/domain/order_history_filter.dart';
import 'package:servis_ku/ui/features/customer/widgets/customer_empty_state.dart';
import 'package:servis_ku/ui/features/customer/widgets/customer_filter_chips.dart';
import 'package:servis_ku/ui/features/customer/widgets/order_summary_card.dart';

class OrderHistoryView extends StatefulWidget {
  const OrderHistoryView({super.key});

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerOrderCubit>().loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<CustomerOrderCubit, CustomerOrderState>(
          listenWhen: (prev, curr) =>
              curr.status == OrderListStatus.loaded &&
              curr.errorMessage != null &&
              prev.errorMessage != curr.errorMessage,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Text(
                    'Riwayat',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                CustomerFilterChips<OrderHistoryFilter>(
                  options: OrderHistoryFilter.values,
                  selected: state.filter,
                  labelOf: (filter) => filter.label,
                  onSelected: context.read<CustomerOrderCubit>().setFilter,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<CustomerOrderCubit>().loadOrders(),
                    child: _buildContent(context, state),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, CustomerOrderState state) {
    if (state.status == OrderListStatus.initial ||
        state.status == OrderListStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == OrderListStatus.failure) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        children: [
          const SizedBox(height: 48),
          Text(
            state.errorMessage ?? 'Gagal memuat riwayat pesanan.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.read<CustomerOrderCubit>().loadOrders(),
            child: const Text('Coba lagi'),
          ),
        ],
      );
    }

    final orders = state.filteredOrders;

    if (orders.isEmpty) {
      final isAll = state.filter == OrderHistoryFilter.semua;
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 32),
          CustomerEmptyState(
            title: 'Belum ada riwayat pesanan',
            subtitle: isAll
                ? 'Tentukan layanan pertamamu sekarang'
                : 'Belum ada pesanan dengan status ${state.filter.label.toLowerCase()}.',
            actionText: isAll ? 'Cari Layanan' : null,
            onAction: isAll ? () => context.go('/customer/home') : null,
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderSummaryCard(
          title: order.shopName,
          order: order,
          onTap: () => context.push('/customer/order/${order.id}'),
        );
      },
    );
  }
}
