import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final double spacing;
  final Color color;
  final Color emptyColor;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.spacing = 2,
    this.color = const Color(0xFFFBBF24),
    this.emptyColor = const Color(0xFFD1D5DB),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < rating.round();
        return Padding(
          padding: EdgeInsets.only(right: index < 4 ? spacing : 0),
          child: Icon(
            Icons.star_rounded,
            size: size,
            color: filled ? color : emptyColor,
          ),
        );
      }),
    );
  }
}
