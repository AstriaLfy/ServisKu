import 'package:equatable/equatable.dart';
import 'package:servis_ku/ui/features/customer/address/domain/customer_address.dart';

enum AddressStatus { initial, loading, loaded, failure }

class AddressState extends Equatable {
  final AddressStatus status;
  final AddressBook book;
  final bool isSaving;
  final String? errorMessage;

  const AddressState({
    this.status = AddressStatus.initial,
    this.book = const AddressBook(),
    this.isSaving = false,
    this.errorMessage,
  });

  List<CustomerAddress> get addresses => book.addresses;

  CustomerAddress? get selectedAddress => book.selectedAddress;

  AddressState copyWith({
    AddressStatus? status,
    AddressBook? book,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddressState(
      status: status ?? this.status,
      book: book ?? this.book,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, book, isSaving, errorMessage];
}
