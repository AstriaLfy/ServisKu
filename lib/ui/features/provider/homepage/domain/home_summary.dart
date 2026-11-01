import 'package:equatable/equatable.dart';

class HomeSummary extends Equatable {
  final int revenueToday;
  final int revenueYesterday;
  final int ordersToday;
  final int completedToday;
  final double ratingAvg;
  final int ratingCount;

  const HomeSummary({
    this.revenueToday = 0,
    this.revenueYesterday = 0,
    this.ordersToday = 0,
    this.completedToday = 0,
    this.ratingAvg = 0.0,
    this.ratingCount = 0,
  });

  factory HomeSummary.fromMap(Map<String, dynamic> map) {
    return HomeSummary(
      revenueToday: (map['revenue_today'] as num?)?.toInt() ?? 0,
      revenueYesterday: (map['revenue_yesterday'] as num?)?.toInt() ?? 0,
      ordersToday: (map['orders_today'] as num?)?.toInt() ?? 0,
      completedToday: (map['completed_today'] as num?)?.toInt() ?? 0,
      ratingAvg: (map['rating_avg'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (map['rating_count'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        revenueToday,
        revenueYesterday,
        ordersToday,
        completedToday,
        ratingAvg,
        ratingCount,
      ];
}
