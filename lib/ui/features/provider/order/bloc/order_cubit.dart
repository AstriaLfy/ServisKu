import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/order_repository.dart';
import '../domain/order_status.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _orderRepository;
  RealtimeChannel? _subscription;
  String? _shopId;

  OrderCubit({OrderRepository? orderRepository})
      : _orderRepository = orderRepository ?? SupabaseOrderRepository(),
        super(const OrderInitial());

  Future<void> loadOrders() async {
    if (state is! OrderLoaded) {
      emit(const OrderLoading());
    }

    try {
      final orders = await _orderRepository.getOrders();
      final currentFilter = state is OrderLoaded
          ? (state as OrderLoaded).selectedFilter
          : OrderFilter.semua;

      emit(OrderLoaded(allOrders: orders, selectedFilter: currentFilter));

      // Subscribe realtime if not yet subscribed
      if (_subscription == null) {
        _shopId ??= await _orderRepository.getShopId();
        if (_shopId != null) {
          _subscription = _orderRepository.watchOrders(_shopId!, () {
            _refreshSilently();
          });
        }
      }
    } catch (e) {
      emit(OrderFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void setFilter(OrderFilter filter) {
    if (state is OrderLoaded) {
      emit((state as OrderLoaded).copyWith(selectedFilter: filter));
    }
  }

  Future<void> acceptOrder(String id) async {
    if (state is! OrderLoaded) return;
    final currentState = state as OrderLoaded;
    emit(currentState.copyWith(actionInProgressId: id));

    try {
      await _orderRepository.acceptOrder(id);
      await _refreshSilently(message: 'Order berhasil diterima');
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(currentState.copyWith(
        clearActionInProgress: true,
        snackbarMessage: msg,
      ));
      if (msg.contains('Status order sudah berubah')) {
        await _refreshSilently();
      }
    }
  }

  Future<void> rejectOrder(String id, String? reason) async {
    if (state is! OrderLoaded) return;
    final currentState = state as OrderLoaded;
    emit(currentState.copyWith(actionInProgressId: id));

    try {
      await _orderRepository.rejectOrder(id, reason);
      await _refreshSilently(message: 'Order berhasil ditolak');
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(currentState.copyWith(
        clearActionInProgress: true,
        snackbarMessage: msg,
      ));
      if (msg.contains('Status order sudah berubah')) {
        await _refreshSilently();
      }
    }
  }

  void clearSnackbar() {
    if (state is OrderLoaded) {
      emit((state as OrderLoaded).copyWith(clearSnackbar: true));
    }
  }

  Future<void> _refreshSilently({String? message}) async {
    try {
      final orders = await _orderRepository.getOrders();
      if (state is OrderLoaded) {
        final current = state as OrderLoaded;
        emit(current.copyWith(
          allOrders: orders,
          clearActionInProgress: true,
          snackbarMessage: message,
        ));
      } else {
        emit(OrderLoaded(allOrders: orders, snackbarMessage: message));
      }
    } catch (e) {
      if (state is OrderLoaded) {
        emit((state as OrderLoaded).copyWith(clearActionInProgress: true));
      }
    }
  }

  @override
  Future<void> close() {
    _subscription?.unsubscribe();
    return super.close();
  }
}
