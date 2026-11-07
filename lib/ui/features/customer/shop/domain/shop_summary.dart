import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:servis_ku/ui/features/provider/profile/domain/shop_profile.dart';

class RatingSummary extends Equatable {
  final double average;
  final int count;

  const RatingSummary({required this.average, required this.count});

  static const empty = RatingSummary(average: 0, count: 0);

  factory RatingSummary.fromRatings(Iterable<int> ratings) {
    final values = ratings.where((r) => r > 0).toList();
    if (values.isEmpty) return empty;
    final sum = values.fold<int>(0, (total, r) => total + r);
    return RatingSummary(average: sum / values.length, count: values.length);
  }

  bool get hasRating => count > 0;

  String get averageLabel => average.toStringAsFixed(1);

  String get countLabel {
    if (count >= 1000) {
      return '(${NumberFormat.decimalPattern('id_ID').format((count ~/ 1000) * 1000)}+ ulasan)';
    }
    return '($count ulasan)';
  }

  @override
  List<Object?> get props => [average, count];
}

class ShopSummary extends Equatable {
  final String id;
  final String name;
  final String? tagline;
  final String? serviceArea;
  final String? photoUrl;
  final bool isOnline;
  final VerificationStatus verificationStatus;
  final String categoryName;
  final RatingSummary rating;

  const ShopSummary({
    required this.id,
    required this.name,
    this.tagline,
    this.serviceArea,
    this.photoUrl,
    this.isOnline = false,
    this.verificationStatus = VerificationStatus.pending,
    this.categoryName = 'Layanan',
    this.rating = RatingSummary.empty,
  });

  factory ShopSummary.fromMap(
    Map<String, dynamic> map, {
    String? photoUrl,
    String? categoryName,
  }) {
    return ShopSummary(
      id: map['id'] as String,
      name: map['name'] as String? ?? 'Penyedia Jasa',
      tagline: map['tagline'] as String?,
      serviceArea: map['service_area'] as String?,
      photoUrl: photoUrl,
      isOnline: map['is_online'] as bool? ?? false,
      verificationStatus: VerificationStatus.fromString(
        map['verification_status'] as String?,
      ),
      categoryName: categoryName ?? 'Layanan',
      rating: RatingSummary(
        average: (map['rating_avg'] as num?)?.toDouble() ?? 0,
        count: (map['rating_count'] as num?)?.toInt() ?? 0,
      ),
    );
  }

  bool get isVerified => verificationStatus == VerificationStatus.verified;

  String get subtitle {
    final value = tagline?.trim();
    if (value != null && value.isNotEmpty) return value;
    return categoryName;
  }

  ShopSummary copyWith({
    String? categoryName,
    RatingSummary? rating,
  }) {
    return ShopSummary(
      id: id,
      name: name,
      tagline: tagline,
      serviceArea: serviceArea,
      photoUrl: photoUrl,
      isOnline: isOnline,
      verificationStatus: verificationStatus,
      categoryName: categoryName ?? this.categoryName,
      rating: rating ?? this.rating,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        tagline,
        serviceArea,
        photoUrl,
        isOnline,
        verificationStatus,
        categoryName,
        rating,
      ];
}
