import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servis_ku/data/models/order_model.dart';
import 'package:servis_ku/data/repositories/order_repository.dart';
import 'package:servis_ku/core/widgets/navbar.dart';
import 'package:servis_ku/core/widgets/order_card.dart';
import 'package:servis_ku/ui/features/provider/order/bloc/order_cubit.dart';
import 'package:servis_ku/ui/features/provider/order/bloc/order_state.dart';
import 'package:servis_ku/ui/features/provider/order/views/order_detail_view.dart';

class OrderView extends StatelessWidget {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderCubit(OrderRepository())..fetchOrders(),
      child: const _OrderViewBody(),
    );
  }
}

class _OrderViewBody extends StatelessWidget {
  const _OrderViewBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      bottomNavigationBar: Navbar(
        currentIndex: 1,
        items: Navbar.providerItems,
        onTap: (index) {
          if (index != 1) {
            Navigator.pop(context); // sementara, sesuaikan sama router kamu
          }
        },
      ),
      body: SafeArea(
        child: Column(
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

            BlocBuilder<OrderCubit, OrderState>(
              buildWhen: (prev, curr) =>
                  prev.selectedFilter != curr.selectedFilter,
              builder: (context, state) {
                return SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: OrderFilter.values.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = OrderFilter.values[index];
                      final bool isActive = filter == state.selectedFilter;

                      return _FilterChip(
                        label: filter.label,
                        isActive: isActive,
                        onTap: () =>
                            context.read<OrderCubit>().changeFilter(filter),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            Expanded(
              child: BlocBuilder<OrderCubit, OrderState>(
                builder: (context, state) {
                  if (state.status == OrderStatusType.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == OrderStatusType.failure) {
                    return Center(
                      child: Text(
                        state.errorMessage ?? 'Terjadi kesalahan',
                        style: const TextStyle(color: Color(0xFF6B7280)),
                      ),
                    );
                  }

                  final orders = state.filteredOrders;
                  if (orders.isEmpty) {
                    return const Center(
                      child: Text(
                        'Tidak ada order',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return OrderCard(
                        order: order,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context
                                    .read<
                                      OrderCubit
                                    >(), // pakai instance Cubit yang sama
                                child: OrderDetailView(order: order),
                              ),
                            ),
                          );
                        },
                        onReject: () =>
                            context.read<OrderCubit>().rejectOrder(order.id),
                        onAccept: () =>
                            context.read<OrderCubit>().acceptOrder(order.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
