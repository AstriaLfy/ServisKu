import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:servis_ku/core/services/supabase_service.dart';
import 'package:servis_ku/ui/features/provider/report/domain/report_models.dart';

class ReportException implements Exception {
  final String message;
  const ReportException(this.message);

  @override
  String toString() => message;
}

class ReportRepository {
  final SupabaseClient _client;

  ReportRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  Future<String> _requireShopId() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const ReportException('Sesi tidak ditemukan. Silakan login kembali.');
    }

    final shop = await _client
        .from('shops')
        .select('id')
        .eq('owner_id', user.id)
        .maybeSingle();

    if (shop == null) {
      throw const ReportException('Toko belum ditemukan untuk akun ini.');
    }
    return shop['id'] as String;
  }

  Future<List<ReportTransaction>> getCompletedTransactions() async {
    try {
      final shopId = await _requireShopId();
      debugPrint('[Report] getCompletedTransactions shopId=$shopId');

      final rows = await _client
          .from('orders')
          .select('''
            id,
            service_summary,
            estimated_price,
            created_at,
            updated_at,
            customer:profiles!customer_id (
              full_name
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
          .eq('shop_id', shopId)
          .eq('status', 'completed')
          .order('updated_at', ascending: false)
          .limit(500);

      return rows.map(ReportTransaction.fromMap).toList();
    } catch (e) {
      debugPrint('[Report] getCompletedTransactions error: $e');
      throw _handleException(e);
    }
  }

  Future<ProviderBalance?> getBalance() async {
    try {
      final result = await _client.rpc('provider_balance');
      if (result is Map<String, dynamic>) return ProviderBalance.fromMap(result);
      return null;
    } catch (e) {
      debugPrint('[Report] provider_balance error: $e');
      return null;
    }
  }

  Future<Withdrawal> requestWithdrawal() async {
    try {
      debugPrint('[Report] request_withdrawal');
      final result = await _client.rpc('request_withdrawal');
      final row = result is List ? result.first : result;
      return Withdrawal.fromMap(row as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[Report] request_withdrawal error: $e');
      throw _handleException(e);
    }
  }

  ReportException _handleException(Object error) {
    if (error is ReportException) return error;

    if (error is PostgrestException) {
      debugPrint('[Report] PostgrestException code=${error.code}, msg=${error.message}');
      final message = error.message.toLowerCase();
      if (message.contains('insufficient_balance')) {
        return const ReportException('Saldo belum mencapai minimal pencairan Rp50.000.');
      }
      if (message.contains('shop_not_found')) {
        return const ReportException('Toko belum ditemukan untuk akun ini.');
      }
      if (error.code == 'PGRST202') {
        return const ReportException('Fitur pencairan belum aktif di server. Hubungi admin ServisKu.');
      }
      if (error.code == '42501' || message.contains('permission denied')) {
        return const ReportException('Anda tidak punya akses untuk aksi ini.');
      }
      return ReportException(error.message);
    }

    if (error is SocketException ||
        error.toString().toLowerCase().contains('clientexception') ||
        error.toString().toLowerCase().contains('network')) {
      return const ReportException('Tidak ada koneksi internet. Periksa jaringan Anda.');
    }

    return ReportException('Terjadi kesalahan: $error');
  }
}
