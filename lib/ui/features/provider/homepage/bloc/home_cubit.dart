import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../order/domain/order_entity.dart';
import '../data/home_repository.dart';
import '../domain/home_helper.dart';
import '../domain/home_summary.dart';
import '../domain/shop_status.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _homeRepository;
  RealtimeChannel? _subscription;
  Timer? _tickerTimer;
  String? _shopId;

  HomeCubit({HomeRepository? homeRepository})
      : _homeRepository = homeRepository ?? SupabaseHomeRepository(),
        super(const HomeInitial()) {
    _startTicker();
  }

  void _startTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _recalculateIncomingOrders();
    });
  }

  void _recalculateIncomingOrders() {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;
    if (!current.isOnline || !current.isVerified) {
      if (current.incomingOrders.isNotEmpty) {
        emit(current.copyWith(incomingOrders: []));
      }
      return;
    }

    final now = DateTime.now();
    final filtered = HomeHelper.filterIncomingOrders(current.rawPendingOrders, now);
    emit(current.copyWith(incomingOrders: filtered));
  }

  Future<void> load() async {
    if (state is! HomeLoaded) {
      emit(const HomeLoading());
    }

    try {
      final results = await Future.wait([
        _homeRepository.getMyShopStatus(),
        _homeRepository.getDailySummary(),
      ]);

      final shopStatus = results[0] as ShopStatus;
      final summary = results[1] as HomeSummary;

      List<OrderEntity> pendingOrders = [];
      if (shopStatus.isOnline && shopStatus.isVerified) {
        pendingOrders = await _homeRepository.getPendingOrders();
      }

      final now = DateTime.now();
      final incomingOrders = (shopStatus.isOnline && shopStatus.isVerified)
          ? HomeHelper.filterIncomingOrders(pendingOrders, now)
          : <OrderEntity>[];

      _shopId = shopStatus.id;
      emit(HomeLoaded(
        shopStatus: shopStatus,
        summary: summary,
        rawPendingOrders: pendingOrders,
        incomingOrders: incomingOrders,
      ));

      _subscribeRealtime();
    } catch (e) {
      debugPrint('[HomeCubit] load error: $e');
      if (state is! HomeLoaded) {
        emit(HomeFailure(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  void _subscribeRealtime() {
    if (_subscription != null || _shopId == null) return;
    _subscription = _homeRepository.watchOrders(_shopId!, () {
      _silentRefresh();
    });
  }

  Future<void> toggleOnline(bool targetOnline) async {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;
    if (current.isTogglingOnline) return;

    // Optimistic update
    final originalStatus = current.shopStatus;
    final optimisticStatus = originalStatus.copyWith(isOnline: targetOnline);
    emit(current.copyWith(
      shopStatus: optimisticStatus,
      isTogglingOnline: true,
      clearSnackbar: true,
    ));

    try {
      final updatedStatus = await _homeRepository.setOnline(targetOnline);

      List<OrderEntity> rawOrders = [];
      List<OrderEntity> incoming = [];

      if (updatedStatus.isOnline && updatedStatus.isVerified) {
        rawOrders = await _homeRepository.getPendingOrders();
        incoming = HomeHelper.filterIncomingOrders(rawOrders, DateTime.now());
      }

      emit(current.copyWith(
        shopStatus: updatedStatus,
        rawPendingOrders: rawOrders,
        incomingOrders: incoming,
        isTogglingOnline: false,
      ));
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      // Rollback
      emit(current.copyWith(
        shopStatus: originalStatus,
        isTogglingOnline: false,
        snackbarMessage: msg,
      ));
    }
  }

  Future<void> acceptOrder(String id) async {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;
    emit(current.copyWith(actionInProgressId: id, clearSnackbar: true));

    try {
      await _homeRepository.acceptOrder(id);
      await _silentRefresh(message: 'Order berhasil diterima');
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(current.copyWith(
        clearActionInProgress: true,
        snackbarMessage: msg,
      ));
      if (msg.contains('Status order sudah berubah')) {
        await _silentRefresh();
      }
    }
  }

  Future<void> rejectOrder(String id, String? reason) async {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;
    emit(current.copyWith(actionInProgressId: id, clearSnackbar: true));

    try {
      await _homeRepository.rejectOrder(id, reason);
      await _silentRefresh(message: 'Order berhasil ditolak');
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(current.copyWith(
        clearActionInProgress: true,
        snackbarMessage: msg,
      ));
      if (msg.contains('Status order sudah berubah')) {
        await _silentRefresh();
      }
    }
  }

  Future<void> refresh() async {
    await _silentRefresh();
  }

  Future<void> _silentRefresh({String? message}) async {
    if (state is! HomeLoaded) {
      await load();
      return;
    }

    final current = state as HomeLoaded;
    try {
      final results = await Future.wait([
        _homeRepository.getMyShopStatus(),
        _homeRepository.getDailySummary(),
      ]);

      final shopStatus = results[0] as ShopStatus;
      final summary = results[1] as HomeSummary;

      List<OrderEntity> pending = [];
      if (shopStatus.isOnline && shopStatus.isVerified) {
        pending = await _homeRepository.getPendingOrders();
      }

      final incoming = (shopStatus.isOnline && shopStatus.isVerified)
          ? HomeHelper.filterIncomingOrders(pending, DateTime.now())
          : <OrderEntity>[];

      emit(current.copyWith(
        shopStatus: shopStatus,
        summary: summary,
        rawPendingOrders: pending,
        incomingOrders: incoming,
        clearActionInProgress: true,
        snackbarMessage: message,
      ));
    } catch (e) {
      debugPrint('[HomeCubit] silentRefresh error: $e');
      emit(current.copyWith(clearActionInProgress: true));
    }
  }

  void clearSnackbar() {
    if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(clearSnackbar: true));
    }
  }

  @override
  Future<void> close() {
    _tickerTimer?.cancel();
    _subscription?.unsubscribe();
    return super.close();
  }
}
