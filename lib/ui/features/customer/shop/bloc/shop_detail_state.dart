import 'package:equatable/equatable.dart';
import 'package:servis_ku/ui/features/customer/shop/domain/shop_review.dart';
import 'package:servis_ku/ui/features/customer/shop/domain/shop_service.dart';
import 'package:servis_ku/ui/features/customer/shop/domain/shop_summary.dart';

enum ShopDetailStatus { loading, loaded, failure }

class ShopDetailState extends Equatable {
  final ShopDetailStatus status;
  final ShopSummary? shop;
  final List<ShopService> services;
  final List<ShopReview> reviews;
  final String? errorMessage;

  const ShopDetailState({
    this.status = ShopDetailStatus.loading,
    this.shop,
    this.services = const [],
    this.reviews = const [],
    this.errorMessage,
  });

  RatingSummary get rating {
    final shopRating = shop?.rating;
    if (shopRating != null && shopRating.hasRating) return shopRating;
    return RatingSummary.fromRatings(reviews.map((review) => review.rating));
  }

  ShopDetailState copyWith({
    ShopDetailStatus? status,
    ShopSummary? shop,
    List<ShopService>? services,
    List<ShopReview>? reviews,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ShopDetailState(
      status: status ?? this.status,
      shop: shop ?? this.shop,
      services: services ?? this.services,
      reviews: reviews ?? this.reviews,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, shop, services, reviews, errorMessage];
}
