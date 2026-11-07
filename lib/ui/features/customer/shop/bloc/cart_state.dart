import 'package:equatable/equatable.dart';
import 'package:servis_ku/ui/features/customer/shop/domain/cart_item.dart';
import 'package:servis_ku/ui/features/customer/shop/domain/shop_summary.dart';

class CartState extends Equatable {
  final ShopSummary? shop;
  final List<CartItem> items;

  const CartState({this.shop, this.items = const []});

  bool get isEmpty => items.isEmpty;

  int get totalPrice => items.fold<int>(0, (sum, item) => sum + item.subtotal);

  int get totalQuantity => items.fold<int>(0, (sum, item) => sum + item.quantity);

  bool belongsTo(String shopId) => shop?.id == shopId && items.isNotEmpty;

  int quantityOf(String serviceId) =>
      items.where((item) => item.service.id == serviceId).firstOrNull?.quantity ?? 0;

  @override
  List<Object?> get props => [shop, items];
}
