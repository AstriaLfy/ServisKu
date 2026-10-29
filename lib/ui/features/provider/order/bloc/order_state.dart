import 'package:equatable/equatable.dart';
import 'package:servis_ku/data/models/order_model.dart';

enum OrderStatusType { initial, loading, success, failure }

class OrderState extends Equatable {
  final OrderStatusType status;
  final List<OrderModel> allOrders;
  final OrderFilter selectedFilter;
  final String? errorMessage;

  const OrderState({
    this.status = OrderStatusType.initial,
    this.allOrders = const [],
    this.selectedFilter = OrderFilter.semua,
    this.errorMessage,
  });

  List<OrderModel> get filteredOrders =>
      allOrders.where((o) => selectedFilter.matches(o.status)).toList();

  OrderState copyWith({
    OrderStatusType? status,
    List<OrderModel>? allOrders,
    OrderFilter? selectedFilter,
    String? errorMessage,
  }) {
    return OrderState(
      status: status ?? this.status,
      allOrders: allOrders ?? this.allOrders,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, allOrders, selectedFilter, errorMessage];
}
