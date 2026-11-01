import 'package:equatable/equatable.dart';
import '../domain/order_entity.dart';
import '../domain/order_status.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrderLoaded extends OrderState {
  final List<OrderEntity> allOrders;
  final OrderFilter selectedFilter;
  final String? actionInProgressId;
  final String? snackbarMessage;

  const OrderLoaded({
    required this.allOrders,
    this.selectedFilter = OrderFilter.semua,
    this.actionInProgressId,
    this.snackbarMessage,
  });

  List<OrderEntity> get filteredOrders =>
      allOrders.where((o) => selectedFilter.matches(o.status)).toList();

  OrderLoaded copyWith({
    List<OrderEntity>? allOrders,
    OrderFilter? selectedFilter,
    String? actionInProgressId,
    bool clearActionInProgress = false,
    String? snackbarMessage,
    bool clearSnackbar = false,
  }) {
    return OrderLoaded(
      allOrders: allOrders ?? this.allOrders,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      actionInProgressId: clearActionInProgress
          ? null
          : (actionInProgressId ?? this.actionInProgressId),
      snackbarMessage: clearSnackbar
          ? null
          : (snackbarMessage ?? this.snackbarMessage),
    );
  }

  @override
  List<Object?> get props => [
        allOrders,
        selectedFilter,
        actionInProgressId,
        snackbarMessage,
      ];
}

class OrderFailure extends OrderState {
  final String message;

  const OrderFailure(this.message);

  @override
  List<Object?> get props => [message];
}
