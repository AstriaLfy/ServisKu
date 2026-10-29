import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servis_ku/data/models/order_model.dart';
import 'package:servis_ku/data/repositories/order_repository.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _repository;

  OrderCubit(this._repository) : super(const OrderState());

  Future<void> fetchOrders() async {
    emit(state.copyWith(status: OrderStatusType.loading));
    try {
      final orders = await _repository.getOrders();
      emit(state.copyWith(status: OrderStatusType.success, allOrders: orders));
    } catch (e) {
      emit(
        state.copyWith(
          status: OrderStatusType.failure,
          errorMessage: 'Gagal memuat order',
        ),
      );
    }
  }

  void changeFilter(OrderFilter filter) {
    emit(state.copyWith(selectedFilter: filter));
  }

  Future<void> acceptOrder(String orderId) async {
    await _repository.acceptOrder(orderId);
    fetchOrders(); // refresh list setelah accept
  }

  Future<void> rejectOrder(String orderId) async {
    await _repository.rejectOrder(orderId);
    fetchOrders();
  }

  Future<void> completeOrder(String orderId) async {
    await _repository.completeOrder(orderId);
    fetchOrders();
  }
}
