import 'package:equatable/equatable.dart';
import '../../order/domain/order_entity.dart';
import '../domain/home_summary.dart';
import '../domain/shop_status.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final ShopStatus shopStatus;
  final HomeSummary summary;
  final List<OrderEntity> rawPendingOrders;
  final List<OrderEntity> incomingOrders;
  final bool isTogglingOnline;
  final String? actionInProgressId;
  final String? snackbarMessage;

  const HomeLoaded({
    required this.shopStatus,
    required this.summary,
    this.rawPendingOrders = const [],
    this.incomingOrders = const [],
    this.isTogglingOnline = false,
    this.actionInProgressId,
    this.snackbarMessage,
  });

  bool get isOnline => shopStatus.isOnline;
  bool get isVerified => shopStatus.isVerified;

  HomeLoaded copyWith({
    ShopStatus? shopStatus,
    HomeSummary? summary,
    List<OrderEntity>? rawPendingOrders,
    List<OrderEntity>? incomingOrders,
    bool? isTogglingOnline,
    String? actionInProgressId,
    bool clearActionInProgress = false,
    String? snackbarMessage,
    bool clearSnackbar = false,
  }) {
    return HomeLoaded(
      shopStatus: shopStatus ?? this.shopStatus,
      summary: summary ?? this.summary,
      rawPendingOrders: rawPendingOrders ?? this.rawPendingOrders,
      incomingOrders: incomingOrders ?? this.incomingOrders,
      isTogglingOnline: isTogglingOnline ?? this.isTogglingOnline,
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
        shopStatus,
        summary,
        rawPendingOrders,
        incomingOrders,
        isTogglingOnline,
        actionInProgressId,
        snackbarMessage,
      ];
}

class HomeFailure extends HomeState {
  final String message;

  const HomeFailure(this.message);

  @override
  List<Object?> get props => [message];
}
