import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

enum ReviewFilter {
  terbaru(null),
  bintang5(5),
  bintang4(4),
  bintang3(3),
  bintang2(2),
  bintang1(1);

  final int? stars;

  const ReviewFilter(this.stars);

  String get label => stars == null ? 'Terbaru' : '$stars Bintang';
}

class ShopReview extends Equatable {
  final String orderId;
  final String reviewerName;
  final int rating;
  final String? review;
  final DateTime reviewedAt;

  const ShopReview({
    required this.orderId,
    required this.reviewerName,
    required this.rating,
    this.review,
    required this.reviewedAt,
  });

  factory ShopReview.fromMap(Map<String, dynamic> map) {
    final ratedAt = map['rated_at'];
    final name = (map['reviewer_name'] as String?)?.trim();

    return ShopReview(
      orderId: map['order_id'] as String,
      reviewerName: name == null || name.isEmpty ? 'Pelanggan' : name,
      rating: (map['rating'] as num?)?.toInt() ?? 0,
      review: map['review'] as String?,
      reviewedAt: ratedAt != null
          ? DateTime.tryParse(ratedAt.toString())?.toLocal() ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String get formattedDate => DateFormat('dd MMMM yyyy', 'id_ID').format(reviewedAt);

  @override
  List<Object?> get props => [orderId, reviewerName, rating, review, reviewedAt];
}
