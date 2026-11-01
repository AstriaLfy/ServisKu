import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../order/data/order_repository.dart';
import '../../order/domain/order_entity.dart';
import '../../profile/domain/shop_profile.dart';
import '../domain/home_summary.dart';
import '../domain/shop_status.dart';

abstract class HomeRepository {
  Future<ShopStatus> getMyShopStatus();
  Future<HomeSummary> getDailySummary();
  Future<ShopStatus> setOnline(bool isOnline);
  Future<List<OrderEntity>> getPendingOrders();
  Future<void> acceptOrder(String id);
  Future<void> rejectOrder(String id, String? reason);
  RealtimeChannel? watchOrders(String shopId, VoidCallback onDataChanged);
}

class SupabaseHomeRepository implements HomeRepository {
  final SupabaseClient _client;
  final OrderRepository _orderRepository;

  SupabaseHomeRepository({
    SupabaseClient? client,
    OrderRepository? orderRepository,
  })  : _client = client ?? Supabase.instance.client,
        _orderRepository = orderRepository ?? SupabaseOrderRepository(client: client);

  @override
  Future<ShopStatus> getMyShopStatus() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const AuthException('Sesi tidak ditemukan. Silakan login kembali.');
      }

      final data = await _client
          .from('shops')
          .select('id, name, photo_path, is_online, verification_status, updated_at')
          .eq('owner_id', user.id)
          .maybeSingle();

      if (data == null) {
        throw const PostgrestException(message: 'Toko belum terdaftar.');
      }

      String? photoUrl;
      final photoPath = data['photo_path'] as String?;
      if (photoPath != null && photoPath.isNotEmpty) {
        final rawUrl = _client.storage.from('shop-photos').getPublicUrl(photoPath);
        final updatedAt = data['updated_at'] != null
            ? DateTime.tryParse(data['updated_at'].toString())?.millisecondsSinceEpoch
            : DateTime.now().millisecondsSinceEpoch;
        photoUrl = '$rawUrl?v=$updatedAt';
      }

      return ShopStatus(
        id: data['id'] as String,
        name: data['name'] as String? ?? 'Toko',
        photoUrl: photoUrl,
        isOnline: data['is_online'] as bool? ?? false,
        verificationStatus: VerificationStatus.fromString(
          data['verification_status'] as String?,
        ),
      );
    } catch (e) {
      debugPrint('[Home] getMyShopStatus error: $e');
      throw _handleException(e);
    }
  }

  @override
  Future<HomeSummary> getDailySummary() async {
    try {
      final res = await _client.rpc('provider_daily_summary');
      if (res is List && res.isNotEmpty) {
        return HomeSummary.fromMap(res.first as Map<String, dynamic>);
      }
      return const HomeSummary();
    } catch (e) {
      debugPrint('[Home] getDailySummary error: $e');
      throw _handleException(e);
    }
  }

  @override
  Future<ShopStatus> setOnline(bool isOnline) async {
    try {
      final res = await _client.rpc('set_shop_online', params: {
        'p_online': isOnline,
      });

      Map<String, dynamic> data;
      if (res is List && res.isNotEmpty) {
        data = res.first as Map<String, dynamic>;
      } else if (res is Map<String, dynamic>) {
        data = res;
      } else {
        // fallback to reading shop status
        return await getMyShopStatus();
      }

      String? photoUrl;
      final photoPath = data['photo_path'] as String?;
      if (photoPath != null && photoPath.isNotEmpty) {
        final rawUrl = _client.storage.from('shop-photos').getPublicUrl(photoPath);
        final updatedAt = data['updated_at'] != null
            ? DateTime.tryParse(data['updated_at'].toString())?.millisecondsSinceEpoch
            : DateTime.now().millisecondsSinceEpoch;
        photoUrl = '$rawUrl?v=$updatedAt';
      }

      return ShopStatus(
        id: data['id'] as String,
        name: data['name'] as String? ?? 'Toko',
        photoUrl: photoUrl,
        isOnline: data['is_online'] as bool? ?? isOnline,
        verificationStatus: VerificationStatus.fromString(
          data['verification_status'] as String?,
        ),
      );
    } catch (e) {
      debugPrint('[Home] setOnline error: $e');
      throw _handleException(e);
    }
  }

  @override
  Future<List<OrderEntity>> getPendingOrders() {
    return _orderRepository.getPendingOrders();
  }

  @override
  Future<void> acceptOrder(String id) {
    return _orderRepository.acceptOrder(id);
  }

  @override
  Future<void> rejectOrder(String id, String? reason) {
    return _orderRepository.rejectOrder(id, reason);
  }

  @override
  RealtimeChannel? watchOrders(String shopId, VoidCallback onDataChanged) {
    return _orderRepository.watchOrders(
      shopId,
      onDataChanged,
      channelName: 'public:orders:beranda_shop_$shopId',
    );
  }

  Exception _handleException(dynamic error) {
    if (error is PostgrestException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('shop_not_verified')) {
        return Exception('Akun belum terverifikasi, belum bisa Online');
      }
      if (msg.contains('shop_not_found')) {
        return Exception('Toko tidak ditemukan');
      }
      if (msg.contains('order_not_actionable')) {
        return Exception('Status order sudah berubah');
      }
      return Exception(error.message);
    }

    if (error is SocketException ||
        error.toString().toLowerCase().contains('clientexception') ||
        error.toString().toLowerCase().contains('network')) {
      return Exception('Tidak ada koneksi internet. Periksa jaringan Anda.');
    }

    if (error is AuthException) {
      return Exception(error.message);
    }

    return Exception(error.toString().replaceAll('Exception: ', ''));
  }
}
