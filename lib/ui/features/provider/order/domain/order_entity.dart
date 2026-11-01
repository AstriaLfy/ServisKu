import 'package:equatable/equatable.dart';
import 'order_status.dart';

class OrderItem extends Equatable {
  final String serviceName;
  final int unitPrice;
  final int quantity;

  const OrderItem({
    required this.serviceName,
    required this.unitPrice,
    required this.quantity,
  });

  int get totalPrice => unitPrice * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem.fromMap(json);

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      serviceName: map['service_name'] as String? ?? 'Layanan',
      unitPrice: (map['unit_price'] as num?)?.toInt() ?? 0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  @override
  List<Object?> get props => [serviceName, unitPrice, quantity];
}

class OrderStatusEvent extends Equatable {
  final OrderStatus status;
  final DateTime changedAt;

  const OrderStatusEvent({
    required this.status,
    required this.changedAt,
  });

  factory OrderStatusEvent.fromJson(Map<String, dynamic> json) => OrderStatusEvent.fromMap(json);

  factory OrderStatusEvent.fromMap(Map<String, dynamic> map) {
    return OrderStatusEvent(
      status: OrderStatus.fromString(map['status'] as String?),
      changedAt: map['changed_at'] != null
          ? DateTime.parse(map['changed_at'].toString()).toLocal()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [status, changedAt];
}

class OrderEntity extends Equatable {
  final String id;
  final String? orderNumber;
  final String customerId;
  final String? shopId;
  final String customerName;
  final String? customerPhone;
  final String serviceSummary;
  final int estimatedPrice;
  final int? estimatedMinutes;
  final double? distanceKm;
  final String address;
  final String? customerNote;
  final OrderStatus status;
  final String? reason;
  final int? rating;
  final String? review;
  final DateTime? ratedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<OrderItem> items;
  final List<OrderStatusEvent> history;

  const OrderEntity({
    required this.id,
    this.orderNumber,
    required this.customerId,
    this.shopId,
    required this.customerName,
    this.customerPhone,
    required this.serviceSummary,
    required this.estimatedPrice,
    this.estimatedMinutes,
    this.distanceKm,
    required this.address,
    this.customerNote,
    required this.status,
    this.reason,
    this.rating,
    this.review,
    this.ratedAt,
    required this.createdAt,
    this.updatedAt,
    this.items = const [],
    this.history = const [],
  });

  // Getter alias untuk UI
  String? get cancellationReason => reason;
  String? get customerAddress => address;
  String get serviceName => serviceSummary.isNotEmpty ? serviceSummary : 'Layanan Servis';

  int get effectivePrice {
    if (items.isNotEmpty) {
      return items.fold<int>(0, (sum, item) => sum + item.totalPrice);
    }
    return estimatedPrice;
  }

  int? get totalPrice => items.isNotEmpty ? effectivePrice : null;

  factory OrderEntity.fromJson(Map<String, dynamic> json) => OrderEntity.fromMap(json);

  factory OrderEntity.fromMap(Map<String, dynamic> map) {
    final customer = map['customer'] as Map<String, dynamic>?;

    final itemsList = (map['items'] as List?)
            ?.map((i) => OrderItem.fromMap(i as Map<String, dynamic>))
            .toList() ??
        const [];

    final historyList = (map['history'] as List?)
            ?.map((h) => OrderStatusEvent.fromMap(h as Map<String, dynamic>))
            .toList() ??
        const [];

    return OrderEntity(
      id: map['id'] as String,
      orderNumber: map['order_number'] as String?,
      customerId: map['customer_id'] as String? ?? '',
      shopId: map['shop_id'] as String?,
      customerName: customer?['full_name'] as String? ?? 'Pelanggan',
      customerPhone: customer?['phone'] as String?,
      serviceSummary: map['service_summary'] as String? ?? '',
      estimatedPrice: (map['estimated_price'] as num?)?.toInt() ?? 0,
      estimatedMinutes: (map['estimated_minutes'] as num?)?.toInt(),
      distanceKm: (map['distance_km'] as num?)?.toDouble(),
      address: map['address'] as String? ?? '-',
      customerNote: map['customer_note'] as String?,
      status: OrderStatus.fromString(map['status'] as String?),
      reason: map['reason'] as String?,
      rating: (map['rating'] as num?)?.toInt(),
      review: map['review'] as String?,
      ratedAt: map['rated_at'] != null
          ? DateTime.tryParse(map['rated_at'].toString())?.toLocal()
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString()).toLocal()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())?.toLocal()
          : null,
      items: itemsList,
      history: historyList,
    );
  }

  OrderEntity copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? shopId,
    String? customerName,
    String? customerPhone,
    String? serviceSummary,
    int? estimatedPrice,
    int? estimatedMinutes,
    double? distanceKm,
    String? address,
    String? customerNote,
    OrderStatus? status,
    String? reason,
    int? rating,
    String? review,
    DateTime? ratedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItem>? items,
    List<OrderStatusEvent>? history,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      shopId: shopId ?? this.shopId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      serviceSummary: serviceSummary ?? this.serviceSummary,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      address: address ?? this.address,
      customerNote: customerNote ?? this.customerNote,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      ratedAt: ratedAt ?? this.ratedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        customerId,
        shopId,
        customerName,
        customerPhone,
        serviceSummary,
        estimatedPrice,
        estimatedMinutes,
        distanceKm,
        address,
        customerNote,
        status,
        reason,
        rating,
        review,
        ratedAt,
        createdAt,
        updatedAt,
        items,
        history,
      ];
}
