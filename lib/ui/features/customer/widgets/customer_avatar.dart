import 'package:flutter/material.dart';

class CustomerAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final bool isLoading;

  const CustomerAvatar({
    super.key,
    this.imageUrl,
    this.radius = 44,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final fallback = Image.asset(
      'assets/images/avatar_default.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
    final url = imageUrl;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipOval(
            child: url == null || url.isEmpty
                ? fallback
                : Image.network(
                    url,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => fallback,
                    loadingBuilder: (context, child, progress) =>
                        progress == null ? child : fallback,
                  ),
          ),
          if (isLoading)
            ClipOval(
              child: Container(
                color: Colors.black.withValues(alpha: 0.35),
                alignment: Alignment.center,
                child: SizedBox(
                  width: radius * 0.6,
                  height: radius * 0.6,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
