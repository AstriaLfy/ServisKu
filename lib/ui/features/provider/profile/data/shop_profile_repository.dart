import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:servis_ku/core/services/supabase_service.dart';
import 'package:servis_ku/ui/features/provider/profile/domain/operating_hours_helper.dart';
import 'package:servis_ku/ui/features/provider/profile/domain/shop_profile.dart';

class ShopProfileException implements Exception {
  final String message;
  const ShopProfileException(this.message);

  @override
  String toString() => message;
}

class ShopProfileRepository {
  final SupabaseClient _client;

  ShopProfileRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  /// Mengambil profil toko milik user yang sedang login beserta jam operasionalnya.
  Future<ShopProfile> getMyShop() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const ShopProfileException('Sesi tidak ditemukan. Silakan login ulang.');
      }

      debugPrint('[Shop] getMyShop for owner_id=${user.id}');

      final shopData = await _client
          .from('shops')
          .select()
          .eq('owner_id', user.id)
          .maybeSingle();

      if (shopData == null) {
        debugPrint('[Shop] Toko belum dibuat untuk user ${user.id}');
        throw const ShopProfileException(
          'Toko belum terdaftar untuk akun ini. Pastikan akun terdaftar sebagai penyedia jasa.',
        );
      }

      final shopId = shopData['id'] as String;

      // Ambil jam operasional toko
      final hoursData = await _client
          .from('shop_operating_hours')
          .select()
          .eq('shop_id', shopId)
          .order('day_of_week', ascending: true);

      final List<OperatingHour> hours = (hoursData as List)
          .map((h) => OperatingHour.fromMap(h as Map<String, dynamic>))
          .toList();

      // Buat public URL foto dengan cache buster ?v=updated_at_ms
      String? photoUrl;
      final photoPath = shopData['photo_path'] as String?;
      if (photoPath != null && photoPath.isNotEmpty) {
        final rawUrl = _client.storage.from('shop-photos').getPublicUrl(photoPath);
        final updatedAt = shopData['updated_at'] != null
            ? DateTime.tryParse(shopData['updated_at'].toString())?.millisecondsSinceEpoch
            : DateTime.now().millisecondsSinceEpoch;
        photoUrl = '$rawUrl?v=${updatedAt ?? DateTime.now().millisecondsSinceEpoch}';
      }

      return ShopProfile.fromMap(
        shopData,
        photoUrl: photoUrl,
        hours: hours,
      );
    } catch (e) {
      debugPrint('[Shop] getMyShop error: $e');
      if (e is ShopProfileException) rethrow;
      throw _handleException(e);
    }
  }

  /// Update informasi toko: name, tagline, serviceArea.
  /// CATATAN ATURAN: Hanya boleh update: name, tagline, photo_path, service_area.
  /// JANGAN mengirim verification_status/owner_id/id.
  Future<void> updateShopInfo({
    required String shopId,
    String? name,
    String? tagline,
    String? serviceArea,
  }) async {
    try {
      final Map<String, dynamic> payload = {};
      if (name != null) payload['name'] = name.trim();
      if (tagline != null) payload['tagline'] = tagline.trim();
      if (serviceArea != null) payload['service_area'] = serviceArea.trim();

      if (payload.isEmpty) return;

      debugPrint('[Shop] updateShopInfo shopId=$shopId payload=$payload');

      await _client
          .from('shops')
          .update(payload)
          .eq('id', shopId);
    } catch (e) {
      debugPrint('[Shop] updateShopInfo error: $e');
      if (e is ShopProfileException) rethrow;
      throw _handleException(e);
    }
  }

  /// Upload foto toko ke bucket 'shop-photos', path: '{userId}/avatar.jpg', upsert: true.
  /// Kemudian simpan path itu ke shops.photo_path.
  Future<String> uploadShopPhoto({
    required String shopId,
    required File imageFile,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const ShopProfileException('Sesi tidak ditemukan.');
      }

      final photoPath = '${user.id}/avatar.jpg';
      debugPrint('[Shop] uploadShopPhoto to $photoPath');

      // Baca bytes file gambar
      final bytes = await imageFile.readAsBytes();

      await _client.storage.from('shop-photos').uploadBinary(
            photoPath,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      // Update shops.photo_path
      await _client.from('shops').update({
        'photo_path': photoPath,
      }).eq('id', shopId);

      final rawUrl = _client.storage.from('shop-photos').getPublicUrl(photoPath);
      final cacheBustedUrl = '$rawUrl?v=${DateTime.now().millisecondsSinceEpoch}';

      return cacheBustedUrl;
    } catch (e) {
      debugPrint('[Shop] uploadShopPhoto error: $e');
      if (e is ShopProfileException) rethrow;
      throw _handleException(e);
    }
  }

  /// Update jam operasional (hanya update open_time, close_time, is_closed per day_of_week)
  Future<void> updateOperatingHours({
    required String shopId,
    required List<OperatingHour> hours,
  }) async {
    try {
      debugPrint('[Shop] updateOperatingHours for shopId=$shopId (count=${hours.length})');

      for (final h in hours) {
        await _client
            .from('shop_operating_hours')
            .update({
              'open_time': h.isClosed ? null : OperatingHoursHelper.normalizeTime(h.openTime),
              'close_time': h.isClosed ? null : OperatingHoursHelper.normalizeTime(h.closeTime),
              'is_closed': h.isClosed,
            })
            .match({
              'shop_id': shopId,
              'day_of_week': h.dayOfWeek,
            });
      }
    } catch (e) {
      debugPrint('[Shop] updateOperatingHours error: $e');
      if (e is ShopProfileException) rethrow;
      throw _handleException(e);
    }
  }

  ShopProfileException _handleException(dynamic error) {
    if (error is PostgrestException) {
      debugPrint('[Shop] PostgrestException code=${error.code}, message=${error.message}');
      if (error.code == '42501' || error.message.toLowerCase().contains('permission denied')) {
        return const ShopProfileException('Anda tidak punya akses untuk melakukan aksi ini.');
      }
      return ShopProfileException(error.message);
    }

    if (error is StorageException) {
      debugPrint('[Shop] StorageException status=${error.statusCode}, message=${error.message}');
      return ShopProfileException('Gagal mengunggah foto: ${error.message}');
    }

    if (error is SocketException ||
        error.toString().toLowerCase().contains('clientexception') ||
        error.toString().toLowerCase().contains('network')) {
      return const ShopProfileException('Tidak ada koneksi internet. Periksa jaringan Anda.');
    }

    return ShopProfileException('Terjadi kesalahan: ${error.toString()}');
  }
}
