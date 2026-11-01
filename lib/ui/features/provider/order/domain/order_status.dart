import 'package:flutter/material.dart';

enum OrderStatus {
  pending,
  accepted,
  inProgress,
  completed,
  rejected,
  cancelled;

  static OrderStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'accepted':
        return OrderStatus.accepted;
      case 'in_progress':
        return OrderStatus.inProgress;
      case 'completed':
        return OrderStatus.completed;
      case 'rejected':
        return OrderStatus.rejected;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }

  String get dbValue {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.accepted:
        return 'accepted';
      case OrderStatus.inProgress:
        return 'in_progress';
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.rejected:
        return 'rejected';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  /// Badge label di kartu & header
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Baru';
      case OrderStatus.accepted:
      case OrderStatus.inProgress:
        return 'Aktif';
      case OrderStatus.completed:
        return 'Selesai';
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  Color get textColor {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFF1D56CF);
      case OrderStatus.accepted:
      case OrderStatus.inProgress:
        return const Color(0xFFB45309);
      case OrderStatus.completed:
        return const Color(0xFF16A34A);
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
        return const Color(0xFFDC2626);
    }
  }

  Color get bgColor {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFFDBEAFE);
      case OrderStatus.accepted:
      case OrderStatus.inProgress:
        return const Color(0xFFFEF3C7);
      case OrderStatus.completed:
        return const Color(0xFFDCFCE7);
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
        return const Color(0xFFFEE2E2);
    }
  }
}

enum OrderFilter { semua, baru, aktif, selesai, dibatalkan }

extension OrderFilterX on OrderFilter {
  String get label {
    switch (this) {
      case OrderFilter.semua:
        return 'Semua';
      case OrderFilter.baru:
        return 'Baru';
      case OrderFilter.aktif:
        return 'Aktif';
      case OrderFilter.selesai:
        return 'Selesai';
      case OrderFilter.dibatalkan:
        return 'Dibatalkan';
    }
  }

  bool matches(OrderStatus status) {
    switch (this) {
      case OrderFilter.semua:
        return true;
      case OrderFilter.baru:
        return status == OrderStatus.pending;
      case OrderFilter.aktif:
        return status == OrderStatus.accepted || status == OrderStatus.inProgress;
      case OrderFilter.selesai:
        return status == OrderStatus.completed;
      case OrderFilter.dibatalkan:
        return status == OrderStatus.rejected || status == OrderStatus.cancelled;
    }
  }
}
