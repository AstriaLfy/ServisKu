import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servis_ku/ui/features/customer/shop/bloc/shop_detail_cubit.dart';
import 'package:servis_ku/ui/features/customer/shop/bloc/shop_detail_state.dart';
import 'package:servis_ku/ui/features/customer/shop/domain/shop_review.dart';
import 'package:servis_ku/ui/features/customer/widgets/customer_empty_state.dart';
import 'package:servis_ku/ui/features/customer/widgets/customer_filter_chips.dart';
import 'package:servis_ku/ui/features/customer/widgets/customer_page_header.dart';
import 'package:servis_ku/ui/features/customer/widgets/rating_stars.dart';
import 'package:servis_ku/ui/features/customer/widgets/shop_info_card.dart';

class ShopReviewView extends StatefulWidget {
  const ShopReviewView({super.key});

  @override
  State<ShopReviewView> createState() => _ShopReviewViewState();
}

class _ShopReviewViewState extends State<ShopReviewView> {
  ReviewFilter _filter = ReviewFilter.terbaru;

  List<ShopReview> _applyFilter(List<ShopReview> reviews) {
    final stars = _filter.stars;
    final filtered = stars == null
        ? List<ShopReview>.from(reviews)
        : reviews.where((review) => review.rating == stars).toList();
    filtered.sort((a, b) => b.reviewedAt.compareTo(a.reviewedAt));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<ShopDetailCubit, ShopDetailState>(
          builder: (context, state) {
            final shop = state.shop;
            final reviews = _applyFilter(state.reviews);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: CustomerBackButton(),
                ),
                if (shop != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ShopInfoCard(shop: shop, rating: state.rating),
                  ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text(
                    'Review',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                CustomerFilterChips<ReviewFilter>(
                  options: ReviewFilter.values,
                  selected: _filter,
                  labelOf: (filter) => filter.label,
                  onSelected: (filter) => setState(() => _filter = filter),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<ShopDetailCubit>().load(),
                    child: _buildList(state, reviews),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(ShopDetailState state, List<ShopReview> reviews) {
    if (state.status == ShopDetailStatus.loading && state.reviews.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reviews.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          CustomerEmptyState(
            title: 'Belum ada review',
            subtitle: _filter == ReviewFilter.terbaru
                ? 'Penyedia jasa ini belum menerima ulasan.'
                : 'Belum ada ulasan dengan ${_filter.label.toLowerCase()}.',
            imageSize: 110,
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: reviews.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 24, color: Color(0xFFE5E7EB)),
      itemBuilder: (context, index) => _ReviewTile(review: reviews[index]),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ShopReview review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final text = review.review?.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFFE5E7EB),
            child: Icon(Icons.person, size: 18, color: Colors.white),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      review.reviewerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  Text(
                    review.formattedDate,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              RatingStars(rating: review.rating.toDouble(), size: 14, spacing: 1),
              if (text != null && text.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
