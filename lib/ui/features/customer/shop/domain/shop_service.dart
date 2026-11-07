import 'package:equatable/equatable.dart';

class ShopService extends Equatable {
  final String id;
  final String shopId;
  final int categoryId;
  final String categoryName;
  final String name;
  final int price;
  final String? description;
  final String? photoUrl;

  const ShopService({
    required this.id,
    required this.shopId,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.price,
    this.description,
    this.photoUrl,
  });

  factory ShopService.fromMap(Map<String, dynamic> map, {String? photoUrl}) {
    final category = map['service_categories'] as Map<String, dynamic>?;
    return ShopService(
      id: map['id'] as String,
      shopId: map['shop_id'] as String,
      categoryId: (map['category_id'] as num?)?.toInt() ?? 0,
      categoryName: category?['name'] as String? ?? '',
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toInt() ?? 0,
      description: map['description'] as String?,
      photoUrl: photoUrl,
    );
  }

  String get subtitle {
    final text = description?.trim();
    if (text != null && text.isNotEmpty) return text;
    return categoryName.isEmpty ? 'Layanan' : categoryName;
  }

  @override
  List<Object?> get props =>
      [id, shopId, categoryId, categoryName, name, price, description, photoUrl];
}
