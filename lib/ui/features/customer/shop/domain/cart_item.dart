import 'package:equatable/equatable.dart';
import 'package:servis_ku/ui/features/customer/shop/domain/shop_service.dart';

class CartItem extends Equatable {
  final ShopService service;
  final int quantity;

  const CartItem({required this.service, required this.quantity});

  int get subtotal => service.price * quantity;

  String get summaryLabel =>
      quantity > 1 ? '${service.name} x$quantity' : service.name;

  CartItem copyWith({int? quantity}) {
    return CartItem(service: service, quantity: quantity ?? this.quantity);
  }

  @override
  List<Object?> get props => [service, quantity];
}
