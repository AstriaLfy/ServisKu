import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:servis_ku/core/services/supabase_service.dart';
import 'package:servis_ku/ui/features/customer/shop/data/shop_photo_url.dart';
import 'package:servis_ku/ui/features/customer/shop/domain/shop_review.dart';
import 'package:servis_ku/ui/features/customer/shop/domain/shop_service.dart';
import 'package:servis_ku/ui/features/customer/shop/domain/shop_summary.dart';
import 'package:servis_ku/ui/features/provider/services/domain/service_item.dart';

class CustomerShopException implements Exception {
  final String message;
  const CustomerShopException(this.message);

  @override
  String toString() => message;
}

class CustomerShopRepository {
  final SupabaseClient _client;

  CustomerShopRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  static const String _shopColumns =
      'id, name, tagline, service_area, photo_path, is_online, verification_status, rating_avg, rating_count, updated_at';

  Future<List<ServiceCategory>> getCategories() async {
    try {
      debugPrint('[CustomerShop] getCategories');
      final data = await _client
          .from('service_categories')
          .select()
          .order('sort_order', ascending: true);

      return data.map(ServiceCategory.fromMap).toList();
    } catch (e) {
      debugPrint('[CustomerShop] getCategories error: $e');
      throw _handleException(e);
    }
  }

  Future<List<ShopSummary>> getShops({int? categoryId}) async {
    try {
      debugPrint('[CustomerShop] getShops categoryId=$categoryId');
      var query = _client
          .from('services')
          .select('shop_id, service_categories(name)')
          .eq('is_active', true)
          .isFilter('deleted_at', null);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      final services = await query;

      final categoryByShop = <String, String>{};
      for (final row in services) {
        final shopId = row['shop_id'] as String?;
        if (shopId == null) continue;
        final category = row['service_categories'] as Map<String, dynamic>?;
        categoryByShop.putIfAbsent(
          shopId,
          () => category?['name'] as String? ?? 'Layanan',
        );
      }

      if (categoryByShop.isEmpty) return [];

      final shopIds = categoryByShop.keys.toList();
      final shopRows = await _client
          .from('shops')
          .select(_shopColumns)
          .inFilter('id', shopIds);

      final shops = shopRows.map((row) {
        final id = row['id'] as String;
        return ShopSummary.fromMap(
          row,
          photoUrl: _photoUrl(row),
          categoryName: categoryByShop[id],
        );
      }).toList();

      shops.sort((a, b) {
        if (a.isOnline != b.isOnline) return a.isOnline ? -1 : 1;
        return b.rating.average.compareTo(a.rating.average);
      });

      return shops;
    } catch (e) {
      debugPrint('[CustomerShop] getShops error: $e');
      throw _handleException(e);
    }
  }

  Future<ShopSummary> getShop(String shopId) async {
    try {
      debugPrint('[CustomerShop] getShop id=$shopId');
      final row = await _client
          .from('shops')
          .select(_shopColumns)
          .eq('id', shopId)
          .maybeSingle();

      if (row == null) {
        throw const CustomerShopException('Penyedia jasa tidak ditemukan.');
      }

      return ShopSummary.fromMap(row, photoUrl: _photoUrl(row));
    } catch (e) {
      debugPrint('[CustomerShop] getShop error: $e');
      throw _handleException(e);
    }
  }

  Future<List<ShopService>> getServices(String shopId) async {
    try {
      debugPrint('[CustomerShop] getServices shopId=$shopId');
      final data = await _client
          .from('services')
          .select('*, service_categories(name)')
          .eq('shop_id', shopId)
          .eq('is_active', true)
          .isFilter('deleted_at', null)
          .order('price', ascending: true);

      return data
          .map((row) => ShopService.fromMap(row, photoUrl: resolveShopPhotoUrl(_client, row)))
          .toList();
    } catch (e) {
      debugPrint('[CustomerShop] getServices error: $e');
      throw _handleException(e);
    }
  }

  Future<List<ShopReview>> getReviews(String shopId) async {
    try {
      debugPrint('[CustomerShop] shop_reviews shopId=$shopId');
      final data = await _client.rpc('shop_reviews', params: {
        'p_shop_id': shopId,
        'p_limit': 100,
      });
      if (data is! List) return const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(ShopReview.fromMap)
          .toList();
    } catch (e) {
      debugPrint('[CustomerShop] shop_reviews error: $e');
      return const [];
    }
  }

  String? _photoUrl(Map<String, dynamic> row) => resolveShopPhotoUrl(_client, row);

  CustomerShopException _handleException(Object error) {
    if (error is CustomerShopException) return error;

    if (error is PostgrestException) {
      debugPrint('[CustomerShop] PostgrestException code=${error.code}, msg=${error.message}');
      if (error.code == '42501' || error.message.toLowerCase().contains('permission denied')) {
        return const CustomerShopException('Anda tidak punya akses untuk melihat data ini.');
      }
      return CustomerShopException(error.message);
    }

    if (error is SocketException ||
        error.toString().toLowerCase().contains('clientexception') ||
        error.toString().toLowerCase().contains('network')) {
      return const CustomerShopException('Tidak ada koneksi internet. Periksa jaringan Anda.');
    }

    return CustomerShopException('Terjadi kesalahan: $error');
  }
}
