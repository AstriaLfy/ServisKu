import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servis_ku/ui/features/customer/address/domain/customer_address.dart';
import 'package:servis_ku/ui/features/customer/booking/data/booking_repository.dart';
import 'package:servis_ku/ui/features/customer/booking/domain/payment_method.dart';
import 'package:servis_ku/ui/features/customer/shop/bloc/cart_state.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository _repository;

  BookingCubit({BookingRepository? repository})
      : _repository = repository ?? BookingRepository(),
        super(const BookingState());

  void setPaymentMethod(PaymentMethod method) {
    emit(state.copyWith(paymentMethod: method));
  }

  void setNote(String note) {
    emit(state.copyWith(note: note));
  }

  Future<void> submit({
    required CartState cart,
    required CustomerAddress? address,
  }) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(status: BookingStatus.idle, clearError: true));

    final shop = cart.shop;
    if (shop == null || cart.isEmpty) {
      emit(state.copyWith(
        status: BookingStatus.failure,
        errorMessage: 'Belum ada layanan yang dipilih.',
      ));
      return;
    }

    if (address == null) {
      emit(state.copyWith(
        status: BookingStatus.failure,
        errorMessage: 'Pilih alamat terlebih dahulu.',
      ));
      return;
    }

    emit(state.copyWith(status: BookingStatus.submitting, clearError: true));

    try {
      final orderId = await _repository.createOrder(
        shopId: shop.id,
        items: cart.items,
        address: address.fullAddress,
        customerNote: state.note,
      );
      emit(state.copyWith(status: BookingStatus.success, createdOrderId: orderId));
    } catch (e) {
      emit(state.copyWith(status: BookingStatus.failure, errorMessage: e.toString()));
    }
  }
}
