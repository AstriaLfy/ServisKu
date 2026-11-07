import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:servis_ku/ui/features/customer/order/data/customer_order_repository.dart';
import 'package:servis_ku/ui/features/customer/order/domain/order_history_filter.dart';
import 'customer_order_state.dart';

class CustomerOrderCubit extends Cubit<CustomerOrderState> {
  final CustomerOrderRepository _repository;
  RealtimeChannel? _subscription;
  String? _subscribedUserId;
  String? _loadedUserId;

  CustomerOrderCubit({CustomerOrderRepository? repository})
      : _repository = repository ?? CustomerOrderRepository(),
        super(const CustomerOrderState());

  Future<void> loadOrders() async {
    final userId = _repository.currentUserId;

    if (userId != _loadedUserId || state.status != OrderListStatus.loaded) {
      emit(CustomerOrderState(
        status: OrderListStatus.loading,
        filter: userId == _loadedUserId ? state.filter : OrderHistoryFilter.semua,
      ));
    }

    try {
      final orders = await _repository.getOrders();
      _loadedUserId = userId;
      emit(state.copyWith(
        status: OrderListStatus.loaded,
        orders: orders,
        clearError: true,
      ));
      _subscribe(userId);
    } catch (e) {
      final hasData = state.status == OrderListStatus.loaded;
      emit(state.copyWith(
        status: hasData ? OrderListStatus.loaded : OrderListStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void setFilter(OrderHistoryFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  void reset() {
    _subscription?.unsubscribe();
    _subscription = null;
    _subscribedUserId = null;
    _loadedUserId = null;
    emit(const CustomerOrderState());
  }

  void _subscribe(String? userId) {
    if (userId == null || userId == _subscribedUserId) return;
    _subscription?.unsubscribe();
    _subscribedUserId = userId;
    _subscription = _repository.watchOrders(
      channelName: 'public:orders:customer_$userId',
      column: 'customer_id',
      value: userId,
      onChanged: _refreshSilently,
    );
  }

  Future<void> _refreshSilently() async {
    try {
      final orders = await _repository.getOrders();
      if (isClosed) return;
      emit(state.copyWith(
        status: OrderListStatus.loaded,
        orders: orders,
        clearError: true,
      ));
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _subscription?.unsubscribe();
    return super.close();
  }
}
