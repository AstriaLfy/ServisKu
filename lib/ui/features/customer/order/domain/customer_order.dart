import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:servis_ku/ui/features/customer/booking/domain/booking_pricing.dart';
import 'package:servis_ku/ui/features/provider/order/domain/order_entity.dart';
import 'package:servis_ku/ui/features/provider/order/domain/order_status.dart';

class CustomerOrder extends Equatable {
  final OrderEntity order;
  final String shopName;
  final String? shopPhotoUrl;

  const CustomerOrder({
    required this.order,
    required this.shopName,
    this.shopPhotoUrl,
  });

  String get id => order.id;
  String? get shopId => order.shopId;
  OrderStatus get status => order.status;
  String get address => order.address;
  String? get note => order.customerNote;
  int? get rating => order.rating;
  String? get review => order.review;
  String? get reason => order.reason;
  DateTime get createdAt => order.createdAt;

  String get displayNumber {
    final number = order.orderNumber;
    if (number != null && number.isNotEmpty) {
      return number.startsWith('#') ? number : '#$number';
    }
    final shortId = order.id.length > 8 ? order.id.substring(0, 8) : order.id;
    return '#${shortId.toUpperCase()}';
  }

  List<String> get serviceLines {
    if (order.items.isNotEmpty) {
      return order.items
          .map((item) => item.quantity > 1
              ? '${item.serviceName} x${item.quantity}'
              : item.serviceName)
          .toList();
    }
    return order.serviceSummary
        .split(',')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  List<PriceLine> get priceLines {
    if (order.items.isNotEmpty) {
      return order.items
          .map((item) => PriceLine(
                item.quantity > 1
                    ? '${item.serviceName} x${item.quantity}'
                    : item.serviceName,
                item.totalPrice,
              ))
          .toList();
    }
    return [PriceLine(order.serviceName, order.effectivePrice)];
  }

  int get subtotal => order.effectivePrice;
  int get serviceFee => BookingPricing.serviceFee;
  int get total => BookingPricing.total(subtotal);

  bool get isActive =>
      status == OrderStatus.pending ||
      status == OrderStatus.accepted ||
      status == OrderStatus.inProgress;

  bool get isCancelled =>
      status == OrderStatus.cancelled || status == OrderStatus.rejected;

  bool get canCancel => status == OrderStatus.pending;

  bool get isRated => rating != null && rating! > 0;

  bool get needsReview => status == OrderStatus.completed && !isRated;

  String get formattedDate =>
      DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(createdAt);

  @override
  List<Object?> get props => [order, shopName, shopPhotoUrl];
}
