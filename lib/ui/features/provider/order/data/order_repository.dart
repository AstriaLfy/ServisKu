import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/order_entity.dart';

abstract class OrderRepository {
  Future<String?> getShopId();
  Future<List<OrderEntity>> getOrders();
  Future<List<OrderEntity>> getPendingOrders();
  Future<OrderEntity> getOrderDetail(String id);
  Future<void> acceptOrder(String id);
  Future<void> rejectOrder(String id, String? reason);
  Future<void> completeOrder(String id);
  RealtimeChannel? watchOrders(String shopId, VoidCallback onDataChanged, {String? channelName});
}

class SupabaseOrderRepository implements OrderRepository {
  final SupabaseClient _client;

  SupabaseOrderRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<String?> getShopId() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final data = await _client
        .from('shops')
        .select('id')
        .eq('owner_id', user.id)
        .maybeSingle();

    if (data == null) return null;
    return data['id'] as String?;
  }

  @override
  Future<List<OrderEntity>> getOrders() async {
    final shopId = await getShopId();
    if (shopId == null) return [];

    try {
      final res = await _client
          .from('orders')
          .select('''
            id,
            order_number,
            customer_id,
            shop_id,
            service_summary,
            estimated_price,
            estimated_minutes,
            distance_km,
            address,
            customer_note,
            status,
            reason,
            rating,
            review,
            rated_at,
            created_at,
            updated_at,
            customer:profiles!customer_id (
              full_name,
              phone
            )
          ''')
          .eq('shop_id', shopId)
          .order('created_at', ascending: false)
          .limit(100);

      final list = res as List<dynamic>;
      return list.map((json) => OrderEntity.fromJson(json as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      debugPrint('[OrderRepository] getOrders error: ${e.message}');
      throw _mapPostgrestException(e);
    } catch (e) {
      debugPrint('[OrderRepository] getOrders general error: $e');
      rethrow;
    }
  }

  @override
  Future<List<OrderEntity>> getPendingOrders() async {
    final shopId = await getShopId();
    if (shopId == null) return [];

    try {
      final res = await _client
          .from('orders')
          .select('''
            id,
            order_number,
            customer_id,
            shop_id,
            service_summary,
            estimated_price,
            estimated_minutes,
            distance_km,
            address,
            customer_note,
            status,
            reason,
            rating,
            review,
            rated_at,
            created_at,
            updated_at,
            customer:profiles!customer_id (
              full_name,
              phone
            )
          ''')
          .eq('shop_id', shopId)
          .eq('status', 'pending')
          .order('created_at', ascending: false)
          .limit(20);

      final list = res as List<dynamic>;
      return list.map((json) => OrderEntity.fromJson(json as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      debugPrint('[OrderRepository] getPendingOrders error: ${e.message}');
      throw _mapPostgrestException(e);
    } catch (e) {
      debugPrint('[OrderRepository] getPendingOrders general error: $e');
      rethrow;
    }
  }

  @override
  Future<OrderEntity> getOrderDetail(String id) async {
    try {
      final res = await _client
          .from('orders')
          .select('''
            id,
            order_number,
            customer_id,
            shop_id,
            service_summary,
            estimated_price,
            estimated_minutes,
            distance_km,
            address,
            customer_note,
            status,
            reason,
            rating,
            review,
            rated_at,
            created_at,
            updated_at,
            customer:profiles!customer_id (
              full_name,
              phone
            ),
            items:order_items (
              service_name,
              unit_price,
              quantity
            ),
            history:order_status_history (
              status,
              changed_at
            )
          ''')
          .eq('id', id)
          .single();

      return OrderEntity.fromJson(res as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      debugPrint('[OrderRepository] getOrderDetail error: ${e.message}');
      throw _mapPostgrestException(e);
    } catch (e) {
      debugPrint('[OrderRepository] getOrderDetail general error: $e');
      rethrow;
    }
  }

  @override
  Future<void> acceptOrder(String id) async {
    try {
      await _client.rpc('respond_to_order', params: {
        'p_order_id': id,
        'p_accept': true,
        'p_reason': null,
      });
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e);
    }
  }

  @override
  Future<void> rejectOrder(String id, String? reason) async {
    try {
      await _client.rpc('respond_to_order', params: {
        'p_order_id': id,
        'p_accept': false,
        'p_reason': (reason != null && reason.trim().isNotEmpty) ? reason.trim() : null,
      });
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e);
    }
  }

  @override
  Future<void> completeOrder(String id) async {
    try {
      await _client.rpc('complete_order', params: {
        'p_order_id': id,
      });
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e);
    }
  }

  @override
  RealtimeChannel? watchOrders(String shopId, VoidCallback onDataChanged, {String? channelName}) {
    try {
      final name = channelName ?? 'public:orders:shop_$shopId';
      final channel = _client.channel(name);
      channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'orders',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'shop_id',
          value: shopId,
        ),
        callback: (payload) {
          debugPrint('[$name Realtime] Order event: ${payload.eventType}');
          onDataChanged();
        },
      ).subscribe();
      return channel;
    } catch (e) {
      debugPrint('[OrderRepository Realtime] Subscription error: $e');
      return null;
    }
  }

  Exception _mapPostgrestException(PostgrestException e) {
    if (e.message.toLowerCase().contains('order_not_actionable')) {
      return Exception('Status order sudah berubah');
    }
    return Exception(e.message);
  }
}
