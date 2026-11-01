import 'package:intl/intl.dart';
import 'package:servis_ku/ui/features/provider/order/domain/order_entity.dart';
import 'package:servis_ku/ui/features/provider/order/domain/order_status.dart';

class OrderTimelineStep {
  final String label;
  final String dateTime;
  final bool isDone;
  final bool isCancelled;

  const OrderTimelineStep({
    required this.label,
    required this.dateTime,
    this.isDone = false,
    this.isCancelled = false,
  });
}

class OrderHelper {
  OrderHelper._();

  /// Helper waktu relatif Bahasa Indonesia:
  /// "Baru saja", "2 menit lalu", "3 jam lalu", "2 hari lalu",
  /// lebih dari 7 hari tampil tanggal (misal "12 Mei 2025").
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays <= 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return DateFormat('d MMMM yyyy', 'id_ID').format(dateTime);
    }
  }

  /// Format tanggal lokal untuk timeline: "12 Mei 2025 | 08.45"
  static String formatTimelineDate(DateTime dateTime) {
    final dateStr = DateFormat('d MMMM yyyy', 'id_ID').format(dateTime);
    final timeStr = DateFormat('HH.mm', 'id_ID').format(dateTime);
    return '$dateStr | $timeStr';
  }

  /// Helper murni untuk membangun langkah-langkah timeline:
  /// Normal flow:
  /// 1. Order Dibuat
  /// 2. Order Diterima
  /// 3. Sedang Dikerjakan
  /// 4. Order Selesai
  ///
  /// Langkah dianggap tercapai jika ada di history ATAU ada langkah setelahnya yang tercapai.
  /// Waktu hanya ditampilkan jika ada di history (selain itu "-").
  ///
  /// Untuk rejected/cancelled:
  /// - Order Dibuat
  /// - "Ditolak" (jika rejected) / "Dibatalkan" (jika cancelled)
  static List<OrderTimelineStep> buildTimeline(OrderEntity order) {
    final history = order.history;
    final status = order.status;

    // Map status -> DateTime dari history
    final Map<OrderStatus, DateTime> historyMap = {};
    for (final h in history) {
      historyMap[h.status] = h.changedAt;
    }

    // Jika dibatalkan atau ditolak
    if (status == OrderStatus.rejected || status == OrderStatus.cancelled) {
      final createdTime = historyMap[OrderStatus.pending] ?? order.createdAt;
      final cancelTime = historyMap[status] ?? history.lastOrNull?.changedAt ?? order.createdAt;
      final cancelLabel = status == OrderStatus.rejected ? 'Ditolak' : 'Dibatalkan';

      return [
        OrderTimelineStep(
          label: 'Order Dibuat',
          dateTime: formatTimelineDate(createdTime),
          isDone: true,
        ),
        OrderTimelineStep(
          label: cancelLabel,
          dateTime: formatTimelineDate(cancelTime),
          isDone: true,
          isCancelled: true,
        ),
      ];
    }

    // Alur Normal (Pending -> Accepted -> InProgress -> Completed)
    final standardStatuses = [
      OrderStatus.pending,
      OrderStatus.accepted,
      OrderStatus.inProgress,
      OrderStatus.completed,
    ];

    final standardLabels = [
      'Order Dibuat',
      'Order Diterima',
      'Sedang Dikerjakan',
      'Order Selesai',
    ];

    // Tentukan index terjauh yang tercapai
    int highestReachedIndex = 0;
    switch (status) {
      case OrderStatus.pending:
        highestReachedIndex = 0;
        break;
      case OrderStatus.accepted:
        highestReachedIndex = 1;
        break;
      case OrderStatus.inProgress:
        highestReachedIndex = 2;
        break;
      case OrderStatus.completed:
        highestReachedIndex = 3;
        break;
      default:
        highestReachedIndex = 0;
    }

    // Cek juga dari riwayat history jika ada status lebih tinggi yang pernah tercatat
    for (int i = 0; i < standardStatuses.length; i++) {
      if (historyMap.containsKey(standardStatuses[i]) && i > highestReachedIndex) {
        highestReachedIndex = i;
      }
    }

    final List<OrderTimelineStep> steps = [];
    for (int i = 0; i < standardStatuses.length; i++) {
      final st = standardStatuses[i];
      final bool isDone = i <= highestReachedIndex;
      final DateTime? eventDate = (i == 0)
          ? (historyMap[st] ?? order.createdAt)
          : historyMap[st];

      steps.add(
        OrderTimelineStep(
          label: standardLabels[i],
          dateTime: eventDate != null ? formatTimelineDate(eventDate) : '-',
          isDone: isDone,
        ),
      );
    }

    return steps;
  }
}
