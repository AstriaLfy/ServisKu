import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:servis_ku/core/services/supabase_service.dart';
import 'package:servis_ku/ui/features/provider/services/domain/service_item.dart';

class ServicesException implements Exception {
  final String message;
  const ServicesException(this.message);

  @override
  String toString() => message;
}

class ServicesRepository {
  final SupabaseClient _client;

  ServicesRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  /// Mengambil daftar kategori layanan (diurutkan berdasarkan sort_order)
  Future<List<ServiceCategory>> getCategories() async {
    try {
      debugPrint('[Shop] getCategories');
      final data = await _client
          .from('service_categories')
          .select()
          .order('sort_order', ascending: true);

      return (data as List)
          .map((c) => ServiceCategory.fromMap(c as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[Shop] getCategories error: $e');
      if (e is ServicesException) rethrow;
      throw _handleException(e);
    }
  }

  /// Mengambil seluruh layanan milik toko penyedia jasa aktif.
  /// CATATAN ATURAN: Semua query list HARUS memfilter deleted_at IS NULL.
  Future<List<ServiceItem>> getServices() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const ServicesException('Sesi tidak ditemukan.');
      }

      // Cari shop_id milik user
      final shop = await _client
          .from('shops')
          .select('id')
          .eq('owner_id', user.id)
          .maybeSingle();

      if (shop == null) {
        throw const ServicesException('Toko belum ditemukan untuk akun ini.');
      }

      final shopId = shop['id'] as String;
      debugPrint('[Shop] getServices for shopId=$shopId');

      final data = await _client
          .from('services')
          .select('*, service_categories(name)')
          .eq('shop_id', shopId)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      return (data as List)
          .map((item) => _withPhotoUrl(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[Shop] getServices error: $e');
      if (e is ServicesException) rethrow;
      throw _handleException(e);
    }
  }

  /// Menambahkan layanan baru.
  Future<ServiceItem> createService({
    required int categoryId,
    required String name,
    required int price,
    String? photoFilePath,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const ServicesException('Sesi tidak ditemukan.');
      }

      final shop = await _client
          .from('shops')
          .select('id')
          .eq('owner_id', user.id)
          .maybeSingle();

      if (shop == null) {
        throw const ServicesException('Toko belum ditemukan untuk akun ini.');
      }

      final shopId = shop['id'] as String;
      debugPrint('[Shop] createService shopId=$shopId, name=$name, price=$price, cat=$categoryId');

      final inserted = await _client
          .from('services')
          .insert({
            'shop_id': shopId,
            'category_id': categoryId,
            'name': name.trim(),
            'price': price,
            'is_active': true,
          })
          .select('*, service_categories(name)')
          .single();

      final created = ServiceItem.fromMap(inserted);
      if (photoFilePath == null) return created;

      final photoPath = await _uploadServicePhoto(created.id, photoFilePath);
      final updated = await _client
          .from('services')
          .update({'photo_path': photoPath})
          .eq('id', created.id)
          .select('*, service_categories(name)')
          .single();
      return _withPhotoUrl(updated);
    } catch (e) {
      debugPrint('[Shop] createService error: $e');
      if (e is ServicesException) rethrow;
      throw _handleException(e);
    }
  }

  /// Mengupdate layanan yang sudah ada.
  /// CATATAN ATURAN: UPDATE hanya kolom category_id, name, price, is_active, deleted_at.
  Future<void> updateService({
    required String id,
    required int categoryId,
    required String name,
    required int price,
    String? photoFilePath,
    String? previousPhotoPath,
  }) async {
    try {
      debugPrint('[Shop] updateService id=$id, name=$name, price=$price, cat=$categoryId');
      await _client
          .from('services')
          .update({
            'category_id': categoryId,
            'name': name.trim(),
            'price': price,
          })
          .eq('id', id);

      if (photoFilePath != null) {
        final photoPath = await _uploadServicePhoto(id, photoFilePath);
        await _client.from('services').update({'photo_path': photoPath}).eq('id', id);
        await _removeOldPhoto(previousPhotoPath);
      }
    } catch (e) {
      debugPrint('[Shop] updateService error: $e');
      if (e is ServicesException) rethrow;
      throw _handleException(e);
    }
  }

  /// Mengaktifkan atau menonaktifkan status layanan.
  Future<void> setActive(String id, bool isActive) async {
    try {
      debugPrint('[Shop] setActive id=$id, isActive=$isActive');
      await _client
          .from('services')
          .update({
            'is_active': isActive,
          })
          .eq('id', id);
    } catch (e) {
      debugPrint('[Shop] setActive error: $e');
      if (e is ServicesException) rethrow;
      throw _handleException(e);
    }
  }

  /// Menghapus layanan (SOFT DELETE: update deleted_at = now()).
  /// CATATAN ATURAN: TIDAK ADA DELETE FISIK.
  Future<void> deleteService(String id) async {
    try {
      debugPrint('[Shop] soft deleteService id=$id');
      await _client
          .from('services')
          .update({
            'deleted_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      debugPrint('[Shop] deleteService error: $e');
      if (e is ServicesException) rethrow;
      throw _handleException(e);
    }
  }

  ServiceItem _withPhotoUrl(Map<String, dynamic> map) {
    final item = ServiceItem.fromMap(map);
    final path = item.photoPath;
    if (path == null || path.isEmpty) return item;
    final rawUrl = _client.storage.from('shop-photos').getPublicUrl(path);
    final updatedAt = map['updated_at'] != null
        ? DateTime.tryParse(map['updated_at'].toString())?.millisecondsSinceEpoch
        : null;
    return item.copyWith(photoUrl: updatedAt == null ? rawUrl : '$rawUrl?v=$updatedAt');
  }

  Future<String> _uploadServicePhoto(String serviceId, String filePath) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const ServicesException('Sesi tidak ditemukan.');
    }
    final path = '${user.id}/services/$serviceId-${DateTime.now().millisecondsSinceEpoch}.jpg';
    debugPrint('[Shop] uploadServicePhoto path=$path');
    final bytes = await File(filePath).readAsBytes();
    await _client.storage.from('shop-photos').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    return path;
  }

  Future<void> _removeOldPhoto(String? path) async {
    final user = _client.auth.currentUser;
    if (path == null || user == null || !path.startsWith('${user.id}/')) return;
    try {
      await _client.storage.from('shop-photos').remove([path]);
    } catch (e) {
      debugPrint('[Shop] removeOldPhoto error: $e');
    }
  }

  ServicesException _handleException(dynamic error) {
    if (error is StorageException) {
      debugPrint('[Shop] Services StorageException status=${error.statusCode}, msg=${error.message}');
      return ServicesException('Gagal mengunggah foto layanan: ${error.message}');
    }

    if (error is PostgrestException) {
      if (error.code == 'PGRST204' || error.message.contains('photo_path')) {
        return const ServicesException('Foto layanan belum didukung server. Hubungi admin ServisKu.');
      }
      debugPrint('[Shop] Services PostgrestException code=${error.code}, msg=${error.message}');
      if (error.code == '42501' || error.message.toLowerCase().contains('permission denied')) {
        return const ServicesException('Anda tidak punya akses untuk aksi ini.');
      }
      return ServicesException(error.message);
    }

    if (error is SocketException ||
        error.toString().toLowerCase().contains('clientexception') ||
        error.toString().toLowerCase().contains('network')) {
      return const ServicesException('Tidak ada koneksi internet. Periksa jaringan Anda.');
    }

    return ServicesException('Terjadi kesalahan: ${error.toString()}');
  }
}
