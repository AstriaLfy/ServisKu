import 'package:equatable/equatable.dart';

class ServiceCategory extends Equatable {
  final int id;
  final String slug;
  final String name;
  final int sortOrder;

  const ServiceCategory({
    required this.id,
    required this.slug,
    required this.name,
    required this.sortOrder,
  });

  factory ServiceCategory.fromMap(Map<String, dynamic> map) {
    return ServiceCategory(
      id: map['id'] as int,
      slug: map['slug'] as String? ?? '',
      name: map['name'] as String? ?? '',
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, slug, name, sortOrder];
}

class ServiceItem extends Equatable {
  final String id;
  final String shopId;
  final int categoryId;
  final String categoryName;
  final String name;
  final int price; // bigint rupiah bulat
  final bool isActive;
  final DateTime? deletedAt;

  const ServiceItem({
    required this.id,
    required this.shopId,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.price,
    required this.isActive,
    this.deletedAt,
  });

  factory ServiceItem.fromMap(
    Map<String, dynamic> map, {
    String? categoryName,
  }) {
    // categoryName bisa berasal dari join atau mapping kategori
    String resolvedCatName = categoryName ?? '';
    if (resolvedCatName.isEmpty && map['service_categories'] != null) {
      resolvedCatName = map['service_categories']['name'] as String? ?? '';
    }

    return ServiceItem(
      id: map['id'] as String,
      shopId: map['shop_id'] as String,
      categoryId: map['category_id'] as int,
      categoryName: resolvedCatName,
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toInt() ?? 0,
      isActive: map['is_active'] as bool? ?? true,
      deletedAt: map['deleted_at'] != null
          ? DateTime.tryParse(map['deleted_at'].toString())
          : null,
    );
  }

  ServiceItem copyWith({
    String? id,
    String? shopId,
    int? categoryId,
    String? categoryName,
    String? name,
    int? price,
    bool? isActive,
    DateTime? deletedAt,
  }) {
    return ServiceItem(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      name: name ?? this.name,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        shopId,
        categoryId,
        categoryName,
        name,
        price,
        isActive,
        deletedAt,
      ];
}
