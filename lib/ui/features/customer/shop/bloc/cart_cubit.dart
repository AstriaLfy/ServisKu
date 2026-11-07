import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servis_ku/ui/features/customer/shop/domain/cart_item.dart';
import 'package:servis_ku/ui/features/customer/shop/domain/shop_service.dart';
import 'package:servis_ku/ui/features/customer/shop/domain/shop_summary.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  bool isFromAnotherShop(String shopId) =>
      state.items.isNotEmpty && state.shop?.id != shopId;

  void setQuantity({
    required ShopSummary shop,
    required ShopService service,
    required int quantity,
  }) {
    final items = state.shop?.id == shop.id
        ? List<CartItem>.from(state.items)
        : <CartItem>[];

    final index = items.indexWhere((item) => item.service.id == service.id);

    if (quantity <= 0) {
      if (index >= 0) items.removeAt(index);
    } else if (index >= 0) {
      items[index] = items[index].copyWith(quantity: quantity);
    } else {
      items.add(CartItem(service: service, quantity: quantity));
    }

    emit(CartState(shop: items.isEmpty ? null : shop, items: items));
  }

  void updateQuantity(String serviceId, int quantity) {
    final shop = state.shop;
    if (shop == null) return;
    final item = state.items.where((i) => i.service.id == serviceId).firstOrNull;
    if (item == null) return;
    setQuantity(shop: shop, service: item.service, quantity: quantity);
  }

  void remove(String serviceId) => updateQuantity(serviceId, 0);

  void clear() => emit(const CartState());
}
