import 'package:equatable/equatable.dart';
import 'package:servis_ku/ui/features/customer/booking/domain/payment_method.dart';

enum BookingStatus { idle, submitting, success, failure }

class BookingState extends Equatable {
  final PaymentMethod paymentMethod;
  final String note;
  final BookingStatus status;
  final String? createdOrderId;
  final String? errorMessage;

  const BookingState({
    this.paymentMethod = PaymentMethod.transferBank,
    this.note = '',
    this.status = BookingStatus.idle,
    this.createdOrderId,
    this.errorMessage,
  });

  bool get isSubmitting => status == BookingStatus.submitting;

  BookingState copyWith({
    PaymentMethod? paymentMethod,
    String? note,
    BookingStatus? status,
    String? createdOrderId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BookingState(
      paymentMethod: paymentMethod ?? this.paymentMethod,
      note: note ?? this.note,
      status: status ?? this.status,
      createdOrderId: createdOrderId ?? this.createdOrderId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [paymentMethod, note, status, createdOrderId, errorMessage];
}
