import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servis_ku/ui/features/customer/address/data/address_repository.dart';
import 'package:servis_ku/ui/features/customer/address/domain/customer_address.dart';
import 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final AddressRepository _repository;

  AddressCubit({AddressRepository? repository})
      : _repository = repository ?? AddressRepository(),
        super(const AddressState());

  Future<void> load() async {
    if (state.status != AddressStatus.loaded) {
      emit(state.copyWith(status: AddressStatus.loading, clearError: true));
    }

    try {
      final book = await _repository.getAddressBook();
      emit(state.copyWith(status: AddressStatus.loaded, book: book, clearError: true));
    } catch (e) {
      emit(state.copyWith(
        status: state.status == AddressStatus.loaded
            ? AddressStatus.loaded
            : AddressStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<bool> add(CustomerAddress address) {
    final addresses = [...state.addresses, address];
    final selectedId = state.book.selectedId ?? address.id;
    return _save(AddressBook(addresses: addresses, selectedId: selectedId));
  }

  Future<bool> edit(CustomerAddress address) {
    final addresses = state.addresses
        .map((item) => item.id == address.id ? address : item)
        .toList();
    return _save(AddressBook(addresses: addresses, selectedId: state.book.selectedId));
  }

  Future<bool> remove(String addressId) {
    final addresses = state.addresses.where((item) => item.id != addressId).toList();
    final selectedId = state.book.selectedId == addressId
        ? addresses.firstOrNull?.id
        : state.book.selectedId;
    return _save(AddressBook(addresses: addresses, selectedId: selectedId));
  }

  Future<bool> select(String addressId) {
    if (state.book.selectedId == addressId) return Future.value(true);
    return _save(AddressBook(addresses: state.addresses, selectedId: addressId));
  }

  void reset() => emit(const AddressState());

  Future<bool> _save(AddressBook book) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final saved = await _repository.saveAddressBook(book);
      emit(state.copyWith(
        status: AddressStatus.loaded,
        book: saved,
        isSaving: false,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
      return false;
    }
  }
}
