import 'package:flutter/material.dart';
import 'package:servis_ku/core/theme/app_colors.dart';

class CategoryVisual {
  final IconData icon;
  final Color color;
  final String? asset;

  const CategoryVisual(this.icon, this.color, [this.asset]);

  static const String _logistic = 'assets/images/category_logistic.png';
  static const String _cleaning = 'assets/images/category_cleaning.png';
  static const String _events = 'assets/images/category_events.png';
  static const String _service = 'assets/images/category_service.png';
  static const String _digital = 'assets/images/category_digital.png';
  static const String _foods = 'assets/images/category_foods.png';

  static CategoryVisual of(String? name) {
    final value = (name ?? '').toLowerCase();

    bool has(List<String> keywords) => keywords.any(value.contains);
    bool word(String keyword) => RegExp('\\b$keyword\\b').hasMatch(value);

    if (has(['clean', 'bersih', 'cuci', 'laundry'])) {
      return const CategoryVisual(Icons.cleaning_services_rounded, Color(0xFF0EA5E9), _cleaning);
    }
    if (word('ac') || has(['pendingin', 'kulkas'])) {
      return const CategoryVisual(Icons.ac_unit_rounded, Color(0xFF06B6D4), _service);
    }
    if (has(['logistic', 'logistik', 'pindah', 'kirim', 'antar', 'titip'])) {
      return const CategoryVisual(Icons.local_shipping_rounded, Color(0xFFF97316), _logistic);
    }
    if (has(['event', 'acara', 'pesta'])) {
      return const CategoryVisual(Icons.event_rounded, Color(0xFFEC4899), _events);
    }
    if (has(['taman', 'rumput', 'garden', 'kebun'])) {
      return const CategoryVisual(Icons.grass_rounded, Color(0xFF22C55E));
    }
    if (has(['food', 'makan', 'masak', 'catering', 'katering'])) {
      return const CategoryVisual(Icons.restaurant_rounded, Color(0xFFF59E0B), _foods);
    }
    if (has(['digital', 'elektronik', 'komputer', 'laptop', 'gadget'])) {
      return const CategoryVisual(Icons.computer_rounded, Color(0xFF64748B), _digital);
    }
    if (has(['listrik', 'electric'])) {
      return const CategoryVisual(Icons.electrical_services_rounded, Color(0xFFEAB308), _service);
    }
    if (has(['ledeng', 'pipa', 'plumb']) || word('air')) {
      return const CategoryVisual(Icons.plumbing_rounded, Color(0xFF3B82F6), _service);
    }
    if (has(['service', 'servis', 'perbaikan', 'repair', 'maintenance', 'tukang'])) {
      return const CategoryVisual(Icons.build_rounded, Color(0xFF6366F1), _service);
    }
    return const CategoryVisual(Icons.home_repair_service_rounded, AppColors.primary);
  }
}

class CategoryIcon extends StatelessWidget {
  final String? categoryName;
  final double size;

  const CategoryIcon({super.key, required this.categoryName, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final visual = CategoryVisual.of(categoryName);
    final asset = visual.asset;

    if (asset == null) {
      return SizedBox(
        width: size,
        height: size,
        child: Icon(visual.icon, size: size * 0.7, color: visual.color),
      );
    }

    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          Icon(visual.icon, size: size * 0.7, color: visual.color),
    );
  }
}
