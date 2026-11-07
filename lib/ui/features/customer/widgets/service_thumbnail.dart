import 'package:flutter/material.dart';
import 'package:servis_ku/ui/features/customer/widgets/category_visual.dart';

class ServiceThumbnail extends StatelessWidget {
  final String? categoryName;
  final String? imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final double iconSize;

  const ServiceThumbnail({
    super.key,
    this.categoryName,
    this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.iconSize = 36,
  });

  @override
  Widget build(BuildContext context) {
    final visual = CategoryVisual.of(categoryName);

    final placeholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            visual.color.withValues(alpha: 0.14),
            visual.color.withValues(alpha: 0.34),
          ],
        ),
      ),
      child: Center(
        child: CategoryIcon(categoryName: categoryName, size: iconSize * 1.5),
      ),
    );

    final url = imageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: url == null || url.isEmpty
          ? placeholder
          : Image.network(
              url,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => placeholder,
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : placeholder,
            ),
    );
  }
}
