import 'package:servis_ku/ui/features/provider/order/domain/order_status.dart';

enum OrderHistoryFilter {
  semua,
  berlangsung,
  selesai,
  dibatalkan;

  String get label {
    switch (this) {
      case OrderHistoryFilter.semua:
        return 'Semua';
      case OrderHistoryFilter.berlangsung:
        return 'Berlangsung';
      case OrderHistoryFilter.selesai:
        return 'Selesai';
      case OrderHistoryFilter.dibatalkan:
        return 'Dibatalkan';
    }
  }

  bool matches(OrderStatus status) {
    switch (this) {
      case OrderHistoryFilter.semua:
        return true;
      case OrderHistoryFilter.berlangsung:
        return status == OrderStatus.pending ||
            status == OrderStatus.accepted ||
            status == OrderStatus.inProgress;
      case OrderHistoryFilter.selesai:
        return status == OrderStatus.completed;
      case OrderHistoryFilter.dibatalkan:
        return status == OrderStatus.cancelled || status == OrderStatus.rejected;
    }
  }
}
