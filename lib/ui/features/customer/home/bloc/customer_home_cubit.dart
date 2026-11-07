import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servis_ku/ui/features/customer/shop/data/customer_shop_repository.dart';
import 'customer_home_state.dart';

class CustomerHomeCubit extends Cubit<CustomerHomeState> {
  final CustomerShopRepository _repository;

  CustomerHomeCubit({CustomerShopRepository? repository})
      : _repository = repository ?? CustomerShopRepository(),
        super(const CustomerHomeState());

  Future<void> load() async {
    if (state.status != CustomerHomeStatus.loaded) {
      emit(state.copyWith(status: CustomerHomeStatus.loading, clearError: true));
    }

    try {
      final categories = await _repository.getCategories();
      final shops = await _repository.getShops(categoryId: state.selectedCategoryId);

      emit(state.copyWith(
        status: CustomerHomeStatus.loaded,
        categories: categories,
        shops: shops,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CustomerHomeStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> selectCategory(int categoryId) async {
    final isSame = state.selectedCategoryId == categoryId;
    emit(state.copyWith(
      selectedCategoryId: isSame ? null : categoryId,
      clearCategory: isSame,
      isLoadingShops: true,
      clearError: true,
    ));

    try {
      final shops = await _repository.getShops(categoryId: state.selectedCategoryId);
      emit(state.copyWith(shops: shops, isLoadingShops: false));
    } catch (e) {
      emit(state.copyWith(isLoadingShops: false, errorMessage: e.toString()));
    }
  }
}
