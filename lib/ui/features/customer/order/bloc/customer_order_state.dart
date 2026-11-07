import 'package:equatable/equatable.dart';
import 'package:servis_ku/ui/features/customer/order/domain/customer_order.dart';
import 'package:servis_ku/ui/features/customer/order/domain/order_history_filter.dart';

enum OrderListStatus { initial, loading, loaded, failure }

class CustomerOrderState extends Equatable {
  final OrderListStatus status;
  final List<CustomerOrder> orders;
  final OrderHistoryFilter filter;
  final String? errorMessage;

  const CustomerOrderState({
    this.status = OrderListStatus.initial,
    this.orders = const [],
    this.filter = OrderHistoryFilter.semua,
    this.errorMessage,
  });

  List<CustomerOrder> get filteredOrders =>
      orders.where((order) => filter.matches(order.status)).toList();

  List<CustomerOrder> get activeOrders =>
      orders.where((order) => order.isActive).toList();

  CustomerOrderState copyWith({
    OrderListStatus? status,
    List<CustomerOrder>? orders,
    OrderHistoryFilter? filter,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CustomerOrderState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      filter: filter ?? this.filter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, orders, filter, errorMessage];
}
