import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:servis_ku/core/services/supabase_service.dart';
import 'package:servis_ku/ui/features/customer/shop/domain/cart_item.dart';

class BookingException implements Exception {
  final String message;
  const BookingException(this.message);

  @override
  String toString() => message;
}

class BookingRepository {
  final SupabaseClient _client;

  BookingRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  Future<String> createOrder({
    required String shopId,
    required List<CartItem> items,
    required String address,
    String? customerNote,
  }) async {
    try {
      if (_client.auth.currentUser == null) {
        throw const BookingException('Sesi tidak ditemukan. Silakan login kembali.');
      }

      final note = customerNote?.trim();
      debugPrint('[Booking] create_order shopId=$shopId items=${items.length}');

      final result = await _client.rpc('create_order', params: {
        'p_shop_id': shopId,
        'p_items': items
            .map((item) => {
                  'service_id': item.service.id,
                  'quantity': item.quantity,
                })
            .toList(),
        'p_address': address,
        'p_note': note == null || note.isEmpty ? null : note,
      });

      final row = result is List ? result.first : result;
      return (row as Map<String, dynamic>)['id'] as String;
    } catch (e) {
      debugPrint('[Booking] create_order error: $e');
      throw _handleException(e);
    }
  }

  BookingException _handleException(Object error) {
    if (error is BookingException) return error;

    if (error is PostgrestException) {
      debugPrint('[Booking] PostgrestException code=${error.code}, msg=${error.message}');
      final message = error.message.toLowerCase();
      if (message.contains('not_customer')) {
        return const BookingException('Akun ini bukan akun customer.');
      }
      if (message.contains('shop_unavailable')) {
        return const BookingException('Penyedia jasa belum terverifikasi atau tidak tersedia.');
      }
      if (message.contains('shop_offline')) {
        return const BookingException('Penyedia jasa sedang offline. Silakan coba lagi nanti.');
      }
      if (message.contains('address_required')) {
        return const BookingException('Alamat wajib diisi.');
      }
      if (message.contains('items_required') || message.contains('invalid_items')) {
        return const BookingException('Layanan yang dipilih tidak valid atau sudah tidak tersedia.');
      }
      if (error.code == '42501' || message.contains('permission denied')) {
        return const BookingException('Anda tidak punya akses untuk membuat pesanan.');
      }
      return BookingException(error.message);
    }

    if (error is SocketException ||
        error.toString().toLowerCase().contains('clientexception') ||
        error.toString().toLowerCase().contains('network')) {
      return const BookingException('Tidak ada koneksi internet. Periksa jaringan Anda.');
    }

    return BookingException('Terjadi kesalahan: $error');
  }
}
