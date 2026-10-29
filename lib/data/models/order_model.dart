import 'package:flutter/material.dart';

enum OrderStatus { aktif, baru, selesai, dibatalkan }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.aktif:
        return 'Aktif';
      case OrderStatus.baru:
        return 'Baru';
      case OrderStatus.selesai:
        return 'Selesai';
      case OrderStatus.dibatalkan:
        return 'Dibatalkan';
    }
  }

  Color get textColor {
    switch (this) {
      case OrderStatus.aktif:
        return const Color(0xFFB45309);
      case OrderStatus.baru:
        return const Color(0xFF1D56CF);
      case OrderStatus.selesai:
        return const Color(0xFF16A34A);
      case OrderStatus.dibatalkan:
        return const Color(0xFFDC2626);
    }
  }

  Color get bgColor {
    switch (this) {
      case OrderStatus.aktif:
        return const Color(0xFFFEF3C7);
      case OrderStatus.baru:
        return const Color(0xFFDBEAFE);
      case OrderStatus.selesai:
        return const Color(0xFFDCFCE7);
      case OrderStatus.dibatalkan:
        return const Color(0xFFFEE2E2);
    }
  }
}

enum OrderFilter { semua, aktif, baru, selesai, dibatalkan }

extension OrderFilterX on OrderFilter {
  String get label {
    switch (this) {
      case OrderFilter.semua:
        return 'Semua';
      case OrderFilter.aktif:
        return 'Aktif';
      case OrderFilter.baru:
        return 'Baru';
      case OrderFilter.selesai:
        return 'Selesai';
      case OrderFilter.dibatalkan:
        return 'Dibatalkan';
    }
  }

  bool matches(OrderStatus status) {
    if (this == OrderFilter.semua) return true;
    return status.name == name;
  }
}

// Satu baris di timeline "Riwayat Status"
class StatusHistoryItem {
  final String label;
  final String dateTime;
  final bool isDone;
  final bool isCancelled;

  const StatusHistoryItem({
    required this.label,
    required this.dateTime,
    this.isDone = false,
    this.isCancelled = false,
  });
}

class OrderModel {
  final String id;
  final String customerName;
  final String serviceName;
  final String timeAgo;
  final String distance;
  final String price;
  final String estimatedTime;
  final OrderStatus status;

  // Field tambahan buat halaman detail
  final double customerRating;
  final int customerRatingCount;
  final String serviceAddress;
  final String? customerNote;
  final List<StatusHistoryItem> statusHistory;
  final double? orderRating; // rating dari pelanggan setelah selesai
  final String? reviewText;
  final String? cancellationReason;

  const OrderModel({
    required this.id,
    required this.customerName,
    required this.serviceName,
    required this.timeAgo,
    required this.distance,
    required this.price,
    required this.estimatedTime,
    required this.status,
    this.customerRating = 0,
    this.customerRatingCount = 0,
    this.serviceAddress = '-',
    this.customerNote,
    this.statusHistory = const [],
    this.orderRating,
    this.reviewText,
    this.cancellationReason,
  });

  OrderModel copyWith({
    OrderStatus? status,
    List<StatusHistoryItem>? statusHistory,
  }) {
    return OrderModel(
      id: id,
      customerName: customerName,
      serviceName: serviceName,
      timeAgo: timeAgo,
      distance: distance,
      price: price,
      estimatedTime: estimatedTime,
      status: status ?? this.status,
      customerRating: customerRating,
      customerRatingCount: customerRatingCount,
      serviceAddress: serviceAddress,
      customerNote: customerNote,
      statusHistory: statusHistory ?? this.statusHistory,
      orderRating: orderRating,
      reviewText: reviewText,
      cancellationReason: cancellationReason,
    );
  }
}
