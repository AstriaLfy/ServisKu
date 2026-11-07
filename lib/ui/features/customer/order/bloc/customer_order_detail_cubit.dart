import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:servis_ku/ui/features/customer/order/data/customer_order_repository.dart';
import 'customer_order_detail_state.dart';

class CustomerOrderDetailCubit extends Cubit<CustomerOrderDetailState> {
  final String orderId;
  final CustomerOrderRepository _repository;
  RealtimeChannel? _subscription;

  CustomerOrderDetailCubit({
    required this.orderId,
    CustomerOrderRepository? repository,
  })  : _repository = repository ?? CustomerOrderRepository(),
        super(const CustomerOrderDetailState());

  Future<void> load() async {
    if (state.order == null) {
      emit(state.copyWith(status: OrderDetailStatus.loading, clearError: true));
    }

    try {
      final order = await _repository.getOrderDetail(orderId);
      emit(state.copyWith(
        status: OrderDetailStatus.loaded,
        order: order,
        clearError: true,
        clearSuccess: true,
      ));
      _subscription ??= _repository.watchOrders(
        channelName: 'public:orders:detail_$orderId',
        column: 'id',
        value: orderId,
        onChanged: _refreshSilently,
      );
    } catch (e) {
      emit(state.copyWith(
        status: state.order == null ? OrderDetailStatus.failure : OrderDetailStatus.loaded,
        errorMessage: e.toString(),
        clearSuccess: true,
      ));
    }
  }

  Future<void> cancelOrder() async {
    if (state.isActionInProgress) return;
    emit(state.copyWith(isActionInProgress: true, clearError: true, clearSuccess: true));

    try {
      await _repository.cancelOrder(orderId);
      final order = await _repository.getOrderDetail(orderId);
      emit(state.copyWith(
        order: order,
        isActionInProgress: false,
        successMessage: 'Pesanan berhasil dibatalkan',
      ));
    } catch (e) {
      emit(state.copyWith(isActionInProgress: false, errorMessage: e.toString()));
      await _refreshSilently();
    }
  }

  Future<bool> submitReview({required int rating, String? review}) async {
    if (state.isActionInProgress) return false;
    emit(state.copyWith(isActionInProgress: true, clearError: true, clearSuccess: true));

    try {
      await _repository.submitReview(orderId: orderId, rating: rating, review: review);
      final order = await _repository.getOrderDetail(orderId);
      emit(state.copyWith(
        order: order,
        isActionInProgress: false,
        successMessage: 'Terima kasih, review kamu sudah terkirim',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(isActionInProgress: false, errorMessage: e.toString()));
      return false;
    }
  }

  Future<void> _refreshSilently() async {
    try {
      final order = await _repository.getOrderDetail(orderId);
      if (isClosed) return;
      emit(state.copyWith(status: OrderDetailStatus.loaded, order: order));
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _subscription?.unsubscribe();
    return super.close();
  }
}
