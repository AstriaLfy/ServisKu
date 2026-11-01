import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/order_repository.dart';
import 'order_detail_state.dart';

class OrderDetailCubit extends Cubit<OrderDetailState> {
  final OrderRepository _orderRepository;

  OrderDetailCubit({OrderRepository? orderRepository})
      : _orderRepository = orderRepository ?? SupabaseOrderRepository(),
        super(const OrderDetailInitial());

  Future<void> loadOrderDetail(String id) async {
    emit(const OrderDetailLoading());
    try {
      final order = await _orderRepository.getOrderDetail(id);
      emit(OrderDetailLoaded(order: order));
    } catch (e) {
      emit(OrderDetailFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> acceptOrder() async {
    if (state is! OrderDetailLoaded) return;
    final currentState = state as OrderDetailLoaded;
    final orderId = currentState.order.id;

    emit(currentState.copyWith(isActionInProgress: true, clearError: true, clearSuccess: true));
    try {
      await _orderRepository.acceptOrder(orderId);
      final updated = await _orderRepository.getOrderDetail(orderId);
      emit(currentState.copyWith(
        order: updated,
        isActionInProgress: false,
        successMessage: 'Order berhasil diterima',
      ));
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(currentState.copyWith(
        isActionInProgress: false,
        errorMessage: msg,
      ));
      if (msg.contains('Status order sudah berubah')) {
        await _refreshSilently(orderId);
      }
    }
  }

  Future<void> rejectOrder(String? reason) async {
    if (state is! OrderDetailLoaded) return;
    final currentState = state as OrderDetailLoaded;
    final orderId = currentState.order.id;

    emit(currentState.copyWith(isActionInProgress: true, clearError: true, clearSuccess: true));
    try {
      await _orderRepository.rejectOrder(orderId, reason);
      final updated = await _orderRepository.getOrderDetail(orderId);
      emit(currentState.copyWith(
        order: updated,
        isActionInProgress: false,
        successMessage: 'Order berhasil ditolak',
      ));
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(currentState.copyWith(
        isActionInProgress: false,
        errorMessage: msg,
      ));
      if (msg.contains('Status order sudah berubah')) {
        await _refreshSilently(orderId);
      }
    }
  }

  Future<void> completeOrder() async {
    if (state is! OrderDetailLoaded) return;
    final currentState = state as OrderDetailLoaded;
    final orderId = currentState.order.id;

    emit(currentState.copyWith(isActionInProgress: true, clearError: true, clearSuccess: true));
    try {
      await _orderRepository.completeOrder(orderId);
      final updated = await _orderRepository.getOrderDetail(orderId);
      emit(currentState.copyWith(
        order: updated,
        isActionInProgress: false,
        successMessage: 'Order berhasil diselesaikan',
      ));
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(currentState.copyWith(
        isActionInProgress: false,
        errorMessage: msg,
      ));
      if (msg.contains('Status order sudah berubah')) {
        await _refreshSilently(orderId);
      }
    }
  }

  Future<void> _refreshSilently(String orderId) async {
    try {
      final updated = await _orderRepository.getOrderDetail(orderId);
      if (state is OrderDetailLoaded) {
        emit((state as OrderDetailLoaded).copyWith(order: updated));
      }
    } catch (_) {}
  }
}
