import 'package:flutter/material.dart';
import '../../order/domain/order_entity.dart';
import '../../order/domain/order_status.dart';

class RevenuePercentageInfo {
  final String text;
  final IconData? icon;
  final Color color;

  const RevenuePercentageInfo({
    required this.text,
    this.icon,
    required this.color,
  });
}

class RatingInfo {
  final String ratingText;
  final String label;

  const RatingInfo({
    required this.ratingText,
    required this.label,
  });
}

class HomeHelper {
  HomeHelper._();

  /// Menghitung persentase pendapatan vs kemarin:
  /// - yesterday > 0 -> round((today - yesterday) / yesterday * 100)
  ///   -> "12% dari kemarin" (ikon panah naik hijau) atau "-8% dari kemarin" (panah turun merah) atau "0% dari kemarin"
  /// - yesterday == 0 && today == 0 -> "0% dari kemarin" (tanpa tren/abu atau netral)
  /// - yesterday == 0 && today > 0 -> "Baru hari ini" (ikon trending up hijau)
  static RevenuePercentageInfo calculateRevenueComparison({
    required int today,
    required int yesterday,
  }) {
    if (yesterday > 0) {
      final double diff = (today - yesterday) / yesterday * 100.0;
      final int percent = diff.round();
      if (percent > 0) {
        return RevenuePercentageInfo(
          text: '$percent% dari kemarin',
          icon: Icons.trending_up,
          color: const Color(0xFF22C55E),
        );
      } else if (percent < 0) {
        return RevenuePercentageInfo(
          text: '$percent% dari kemarin',
          icon: Icons.trending_down,
          color: const Color(0xFFEF4444),
        );
      } else {
        return const RevenuePercentageInfo(
          text: '0% dari kemarin',
          icon: Icons.trending_flat,
          color: Color(0xFF6B7280),
        );
      }
    } else {
      if (today > 0) {
        return const RevenuePercentageInfo(
          text: 'Baru hari ini',
          icon: Icons.trending_up,
          color: Color(0xFF22C55E),
        );
      } else {
        return const RevenuePercentageInfo(
          text: '0% dari kemarin',
          icon: Icons.trending_flat,
          color: Color(0xFF6B7280),
        );
      }
    }
  }

  /// Menghitung label rating:
  /// - ratingCount == 0 -> "Belum ada ulasan" (angka tampil "0")
  /// - >= 4.5 -> "Sangat Baik"
  /// - >= 4.0 -> "Baik"
  /// - >= 3.0 -> "Cukup"
  /// - selain itu -> "Kurang"
  /// - Rating tampil 1 desimal ("4.8") jika ratingCount > 0
  static RatingInfo calculateRatingInfo({
    required double ratingAvg,
    required int ratingCount,
  }) {
    if (ratingCount == 0) {
      return const RatingInfo(
        ratingText: '0',
        label: 'Belum ada ulasan',
      );
    }

    final ratingFormatted = ratingAvg.toStringAsFixed(1);
    String label;
    if (ratingAvg >= 4.5) {
      label = 'Sangat Baik';
    } else if (ratingAvg >= 4.0) {
      label = 'Baik';
    } else if (ratingAvg >= 3.0) {
      label = 'Cukup';
    } else {
      label = 'Kurang';
    }

    return RatingInfo(
      ratingText: ratingFormatted,
      label: label,
    );
  }

  /// Filter order masuk:
  /// pending && now - createdAt < 5 menit, diurutkan terbaru dulu
  static List<OrderEntity> filterIncomingOrders(
    List<OrderEntity> orders,
    DateTime now,
  ) {
    const fiveMinutes = Duration(minutes: 20);
    final filtered = orders.where((o) {
      if (o.status != OrderStatus.pending) return false;
      final diff = now.difference(o.createdAt);
      return diff >= Duration.zero && diff < fiveMinutes;
    }).toList();

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }
}
