import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class ReportTransaction extends Equatable {
  final String orderId;
  final String customerName;
  final String serviceLabel;
  final int amount;
  final DateTime completedAt;

  const ReportTransaction({
    required this.orderId,
    required this.customerName,
    required this.serviceLabel,
    required this.amount,
    required this.completedAt,
  });

  factory ReportTransaction.fromMap(Map<String, dynamic> map) {
    final customer = map['customer'] as Map<String, dynamic>?;
    final items = (map['items'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? const [];
    final history = (map['history'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? const [];

    final itemsTotal = items.fold<int>(
      0,
      (sum, item) =>
          sum +
          ((item['unit_price'] as num?)?.toInt() ?? 0) *
              ((item['quantity'] as num?)?.toInt() ?? 1),
    );

    DateTime? completedAt;
    for (final entry in history) {
      if (entry['status'] != 'completed') continue;
      final changedAt = DateTime.tryParse(entry['changed_at'].toString());
      if (changedAt != null && (completedAt == null || changedAt.isAfter(completedAt))) {
        completedAt = changedAt;
      }
    }
    completedAt ??= DateTime.tryParse((map['updated_at'] ?? map['created_at']).toString());

    final name = (customer?['full_name'] as String?)?.trim();
    final summary = (map['service_summary'] as String?)?.trim();
    final firstItem = items.isNotEmpty ? items.first['service_name'] as String? : null;

    return ReportTransaction(
      orderId: map['id'] as String,
      customerName: name == null || name.isEmpty ? 'Pelanggan' : name,
      serviceLabel: summary != null && summary.isNotEmpty ? summary : (firstItem ?? 'Layanan'),
      amount: itemsTotal > 0 ? itemsTotal : (map['estimated_price'] as num?)?.toInt() ?? 0,
      completedAt: (completedAt ?? DateTime.now()).toLocal(),
    );
  }

  String get formattedDate => DateFormat('d MMMM yyyy | HH.mm', 'id_ID').format(completedAt);

  @override
  List<Object?> get props => [orderId, customerName, serviceLabel, amount, completedAt];
}

class ReportSummary extends Equatable {
  static const double commissionRate = 0.15;
  static const int commissionPercent = 15;

  final DateTime month;
  final List<ReportTransaction> transactions;

  const ReportSummary({required this.month, required this.transactions});

  factory ReportSummary.forMonth(DateTime month, List<ReportTransaction> all) {
    return ReportSummary(
      month: month,
      transactions: all
          .where((t) => t.completedAt.year == month.year && t.completedAt.month == month.month)
          .toList()
        ..sort((a, b) => b.completedAt.compareTo(a.completedAt)),
    );
  }

  int get gross => transactions.fold<int>(0, (sum, t) => sum + t.amount);

  int get commission => (gross * commissionRate).round();

  int get net => gross - commission;

  String get monthLabel => formatMonth(month);

  static String formatMonth(DateTime month) => DateFormat('MMMM yyyy', 'id_ID').format(month);

  @override
  List<Object?> get props => [month, transactions];
}

class ProviderBalance extends Equatable {
  final int totalNet;
  final int withdrawn;
  final int available;

  const ProviderBalance({
    required this.totalNet,
    required this.withdrawn,
    required this.available,
  });

  factory ProviderBalance.fromMap(Map<String, dynamic> map) {
    return ProviderBalance(
      totalNet: (map['total_net'] as num?)?.toInt() ?? 0,
      withdrawn: (map['withdrawn'] as num?)?.toInt() ?? 0,
      available: (map['available'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [totalNet, withdrawn, available];
}

class Withdrawal extends Equatable {
  static const int minimumAmount = 50000;

  final String id;
  final String reference;
  final int amount;
  final String method;
  final String status;
  final DateTime createdAt;

  const Withdrawal({
    required this.id,
    required this.reference,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
  });

  factory Withdrawal.fromMap(Map<String, dynamic> map) {
    return Withdrawal(
      id: map['id'] as String,
      reference: map['reference'] as String? ?? '-',
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      method: map['method'] as String? ?? 'Transfer Bank',
      status: map['status'] as String? ?? 'pending',
      createdAt: DateTime.tryParse(map['created_at'].toString())?.toLocal() ?? DateTime.now(),
    );
  }

  String get estimatedArrival => DateFormat('d MMMM yyyy | HH.mm', 'id_ID')
      .format(createdAt.add(const Duration(days: 1)));

  @override
  List<Object?> get props => [id, reference, amount, method, status, createdAt];
}
