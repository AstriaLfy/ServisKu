import 'package:equatable/equatable.dart';
import 'package:servis_ku/ui/features/customer/order/domain/customer_order.dart';

enum OrderDetailStatus { loading, loaded, failure }

class CustomerOrderDetailState extends Equatable {
  final OrderDetailStatus status;
  final CustomerOrder? order;
  final bool isActionInProgress;
  final String? successMessage;
  final String? errorMessage;

  const CustomerOrderDetailState({
    this.status = OrderDetailStatus.loading,
    this.order,
    this.isActionInProgress = false,
    this.successMessage,
    this.errorMessage,
  });

  CustomerOrderDetailState copyWith({
    OrderDetailStatus? status,
    CustomerOrder? order,
    bool? isActionInProgress,
    String? successMessage,
    bool clearSuccess = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CustomerOrderDetailState(
      status: status ?? this.status,
      order: order ?? this.order,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        order,
        isActionInProgress,
        successMessage,
        errorMessage,
      ];
}
