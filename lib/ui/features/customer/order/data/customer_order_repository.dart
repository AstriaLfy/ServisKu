import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:servis_ku/core/services/supabase_service.dart';
import 'package:servis_ku/ui/features/customer/order/domain/customer_order.dart';
import 'package:servis_ku/ui/features/customer/shop/data/shop_photo_url.dart';
import 'package:servis_ku/ui/features/provider/order/domain/order_entity.dart';

class CustomerOrderException implements Exception {
  final String message;
  const CustomerOrderException(this.message);

  @override
  String toString() => message;
}

class CustomerOrderRepository {
  final SupabaseClient _client;

  CustomerOrderRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  static const String _listColumns = '''
    id,
    order_number,
    customer_id,
    shop_id,
    service_summary,
    estimated_price,
    address,
    customer_note,
    status,
    reason,
    rating,
    review,
    rated_at,
    created_at,
    updated_at,
    items:order_items (
      service_name,
      unit_price,
      quantity
    )
  ''';

  static const String _detailColumns = '''
    $_listColumns,
    history:order_status_history (
      status,
      changed_at
    )
  ''';

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<List<CustomerOrder>> getOrders() async {
    final userId = currentUserId;
    if (userId == null) {
      throw const CustomerOrderException('Sesi tidak ditemukan. Silakan login kembali.');
    }

    try {
      debugPrint('[CustomerOrder] getOrders customerId=$userId');
      final rows = await _client
          .from('orders')
          .select(_listColumns)
          .eq('customer_id', userId)
          .order('created_at', ascending: false)
          .limit(100);

      return await _attachShops(rows.map(OrderEntity.fromMap).toList());
    } catch (e) {
      debugPrint('[CustomerOrder] getOrders error: $e');
      throw _handleException(e);
    }
  }

  Future<CustomerOrder> getOrderDetail(String orderId) async {
    try {
      debugPrint('[CustomerOrder] getOrderDetail id=$orderId');
      final row = await _client
          .from('orders')
          .select(_detailColumns)
          .eq('id', orderId)
          .single();

      final orders = await _attachShops([OrderEntity.fromMap(row)]);
      return orders.first;
    } catch (e) {
      debugPrint('[CustomerOrder] getOrderDetail error: $e');
      throw _handleException(e);
    }
  }

  Future<void> cancelOrder(String orderId, {String? reason}) async {
    try {
      debugPrint('[CustomerOrder] cancel_order id=$orderId');
      final trimmed = reason?.trim();
      await _client.rpc('cancel_order', params: {
        'p_order_id': orderId,
        'p_reason': trimmed == null || trimmed.isEmpty ? null : trimmed,
      });
    } catch (e) {
      debugPrint('[CustomerOrder] cancel_order error: $e');
      throw _handleException(
        e,
        notActionable: 'Pesanan sudah diproses penyedia jasa dan tidak dapat dibatalkan.',
      );
    }
  }

  Future<void> submitReview({
    required String orderId,
    required int rating,
    String? review,
  }) async {
    try {
      debugPrint('[CustomerOrder] rate_order id=$orderId rating=$rating');
      final trimmed = review?.trim();
      await _client.rpc('rate_order', params: {
        'p_order_id': orderId,
        'p_rating': rating,
        'p_review': trimmed == null || trimmed.isEmpty ? null : trimmed,
      });
    } catch (e) {
      debugPrint('[CustomerOrder] rate_order error: $e');
      throw _handleException(
        e,
        notActionable: 'Review hanya bisa dikirim sekali untuk pesanan yang sudah selesai.',
      );
    }
  }

  RealtimeChannel? watchOrders({
    required String channelName,
    required String column,
    required String value,
    required VoidCallback onChanged,
  }) {
    try {
      final channel = _client.channel(channelName);
      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'orders',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: column,
              value: value,
            ),
            callback: (payload) {
              debugPrint('[$channelName Realtime] Order event: ${payload.eventType}');
              onChanged();
            },
          )
          .subscribe();
      return channel;
    } catch (e) {
      debugPrint('[CustomerOrder Realtime] Subscription error: $e');
      return null;
    }
  }

  Future<List<CustomerOrder>> _attachShops(List<OrderEntity> orders) async {
    final shopIds = orders.map((o) => o.shopId).whereType<String>().toSet().toList();
    final shops = <String, Map<String, dynamic>>{};

    if (shopIds.isNotEmpty) {
      try {
        final rows = await _client
            .from('shops')
            .select('id, name, photo_path, updated_at')
            .inFilter('id', shopIds);
        for (final row in rows) {
          shops[row['id'] as String] = row;
        }
      } catch (e) {
        debugPrint('[CustomerOrder] attachShops error: $e');
      }
    }

    return orders.map((order) {
      final shop = shops[order.shopId];
      return CustomerOrder(
        order: order,
        shopName: shop?['name'] as String? ?? 'Penyedia Jasa',
        shopPhotoUrl: shop == null ? null : resolveShopPhotoUrl(_client, shop),
      );
    }).toList();
  }

  CustomerOrderException _handleException(Object error, {String? notActionable}) {
    if (error is CustomerOrderException) return error;

    if (error is PostgrestException) {
      debugPrint('[CustomerOrder] PostgrestException code=${error.code}, msg=${error.message}');
      final message = error.message.toLowerCase();
      if (message.contains('order_not_actionable')) {
        return CustomerOrderException(notActionable ?? 'Status pesanan sudah berubah.');
      }
      if (message.contains('invalid_rating')) {
        return const CustomerOrderException('Rating harus bernilai 1 sampai 5.');
      }
      if (error.code == 'PGRST202') {
        return const CustomerOrderException('Fitur ini belum aktif di server. Hubungi admin ServisKu.');
      }
      if (error.code == '42501' || message.contains('permission denied')) {
        return const CustomerOrderException('Anda tidak punya akses untuk aksi ini.');
      }
      if (error.code == 'PGRST116') {
        return const CustomerOrderException('Pesanan tidak ditemukan.');
      }
      return CustomerOrderException(error.message);
    }

    if (error is SocketException ||
        error.toString().toLowerCase().contains('clientexception') ||
        error.toString().toLowerCase().contains('network')) {
      return const CustomerOrderException('Tidak ada koneksi internet. Periksa jaringan Anda.');
    }

    return CustomerOrderException('Terjadi kesalahan: $error');
  }
}
