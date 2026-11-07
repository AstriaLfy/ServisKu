import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servis_ku/ui/features/customer/shop/data/customer_shop_repository.dart';
import 'package:servis_ku/ui/features/customer/shop/domain/shop_summary.dart';
import 'shop_detail_state.dart';

class ShopDetailCubit extends Cubit<ShopDetailState> {
  final String shopId;
  final CustomerShopRepository _repository;

  ShopDetailCubit({
    required this.shopId,
    ShopSummary? initialShop,
    CustomerShopRepository? repository,
  })  : _repository = repository ?? CustomerShopRepository(),
        super(ShopDetailState(shop: initialShop));

  Future<void> load() async {
    if (state.status != ShopDetailStatus.loaded) {
      emit(state.copyWith(status: ShopDetailStatus.loading, clearError: true));
    }

    try {
      final shop = await _repository.getShop(shopId);
      final services = await _repository.getServices(shopId);
      final reviews = await _repository.getReviews(shopId);

      final categoryName = services.isNotEmpty
          ? services.first.categoryName
          : state.shop?.categoryName;

      final ratedShop = shop.copyWith(categoryName: categoryName);

      emit(state.copyWith(
        status: ShopDetailStatus.loaded,
        shop: ratedShop,
        services: services,
        reviews: reviews,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: state.status == ShopDetailStatus.loaded
            ? ShopDetailStatus.loaded
            : ShopDetailStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
