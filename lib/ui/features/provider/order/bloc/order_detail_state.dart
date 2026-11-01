import 'package:equatable/equatable.dart';
import '../domain/order_entity.dart';

abstract class OrderDetailState extends Equatable {
  const OrderDetailState();

  @override
  List<Object?> get props => [];
}

class OrderDetailInitial extends OrderDetailState {
  const OrderDetailInitial();
}

class OrderDetailLoading extends OrderDetailState {
  const OrderDetailLoading();
}

class OrderDetailLoaded extends OrderDetailState {
  final OrderEntity order;
  final bool isActionInProgress;
  final String? successMessage;
  final String? errorMessage;

  const OrderDetailLoaded({
    required this.order,
    this.isActionInProgress = false,
    this.successMessage,
    this.errorMessage,
  });

  OrderDetailLoaded copyWith({
    OrderEntity? order,
    bool? isActionInProgress,
    String? successMessage,
    bool clearSuccess = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OrderDetailLoaded(
      order: order ?? this.order,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        order,
        isActionInProgress,
        successMessage,
        errorMessage,
      ];
}

class OrderDetailFailure extends OrderDetailState {
  final String message;

  const OrderDetailFailure(this.message);

  @override
  List<Object?> get props => [message];
}
