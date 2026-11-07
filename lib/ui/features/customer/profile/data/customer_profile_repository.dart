import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:servis_ku/core/services/supabase_service.dart';
import 'package:servis_ku/ui/features/customer/profile/domain/customer_profile.dart';

class CustomerProfileException implements Exception {
  final String message;
  const CustomerProfileException(this.message);

  @override
  String toString() => message;
}

class CustomerProfileRepository {
  final SupabaseClient _client;

  static const String _avatarBucket = 'avatars';

  CustomerProfileRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  User _requireUser() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const CustomerProfileException('Sesi tidak ditemukan. Silakan login kembali.');
    }
    return user;
  }

  Future<CustomerProfile> getProfile() async {
    try {
      final user = _requireUser();
      debugPrint('[CustomerProfile] getProfile userId=${user.id}');

      final row = await _client
          .from('profiles')
          .select('full_name, phone')
          .eq('id', user.id)
          .maybeSingle();

      User freshUser = user;
      try {
        freshUser = (await _client.auth.getUser()).user ?? user;
      } catch (e) {
        debugPrint('[CustomerProfile] getUser fallback: $e');
      }

      return CustomerProfile(
        fullName: row?['full_name'] as String? ?? '',
        phone: row?['phone'] as String? ?? freshUser.phone ?? '',
        email: freshUser.email ?? '',
        bio: freshUser.userMetadata?['bio'] as String? ?? '',
        avatarUrl: _avatarUrl(freshUser.userMetadata),
      );
    } catch (e) {
      debugPrint('[CustomerProfile] getProfile error: $e');
      throw _handleException(e);
    }
  }

  Future<void> updateName(String fullName) async {
    try {
      final user = _requireUser();
      final name = fullName.trim();
      debugPrint('[CustomerProfile] updateName');

      await _client.from('profiles').update({'full_name': name}).eq('id', user.id);
      await _client.auth.updateUser(UserAttributes(data: {'full_name': name}));
    } catch (e) {
      debugPrint('[CustomerProfile] updateName error: $e');
      throw _handleException(e);
    }
  }

  Future<void> updateBio(String bio) async {
    try {
      _requireUser();
      debugPrint('[CustomerProfile] updateBio');
      await _client.auth.updateUser(UserAttributes(data: {'bio': bio.trim()}));
    } catch (e) {
      debugPrint('[CustomerProfile] updateBio error: $e');
      throw _handleException(e);
    }
  }

  Future<void> updateEmail(String email) async {
    try {
      _requireUser();
      debugPrint('[CustomerProfile] updateEmail');
      await _client.auth.updateUser(UserAttributes(email: email.trim()));
    } catch (e) {
      debugPrint('[CustomerProfile] updateEmail error: $e');
      throw _handleException(e);
    }
  }

  Future<void> requestPhoneChange(String phone) async {
    try {
      _requireUser();
      debugPrint('[CustomerProfile] requestPhoneChange phone=$phone');
      await _client.auth.updateUser(UserAttributes(phone: phone));
    } catch (e) {
      debugPrint('[CustomerProfile] requestPhoneChange error: $e');
      throw _handleException(e);
    }
  }

  Future<void> verifyPhoneChange({
    required String phone,
    required String token,
  }) async {
    try {
      debugPrint('[CustomerProfile] verifyPhoneChange phone=$phone');
      await _client.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.phoneChange,
      );
      final user = _requireUser();
      await _client.from('profiles').update({'phone': phone}).eq('id', user.id);
    } catch (e) {
      debugPrint('[CustomerProfile] verifyPhoneChange error: $e');
      throw _handleException(e);
    }
  }

  Future<void> updatePassword(String password) async {
    try {
      _requireUser();
      debugPrint('[CustomerProfile] updatePassword');
      await _client.auth.updateUser(UserAttributes(password: password));
    } catch (e) {
      debugPrint('[CustomerProfile] updatePassword error: $e');
      throw _handleException(e);
    }
  }

  Future<String> uploadAvatar(String filePath) async {
    try {
      final user = _requireUser();
      final path = '${user.id}/profile.jpg';
      debugPrint('[CustomerProfile] uploadAvatar path=$path');

      final bytes = await File(filePath).readAsBytes();
      await _client.storage.from(_avatarBucket).uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
          );

      final version = DateTime.now().millisecondsSinceEpoch;
      final response = await _client.auth.updateUser(
        UserAttributes(data: {'avatar_path': path, 'avatar_version': version}),
      );

      return _avatarUrl(response.user?.userMetadata) ??
          '${_client.storage.from(_avatarBucket).getPublicUrl(path)}?v=$version';
    } catch (e) {
      debugPrint('[CustomerProfile] uploadAvatar error: $e');
      throw _handleException(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      _requireUser();
      debugPrint('[CustomerProfile] delete_my_account');
      await _client.rpc('delete_my_account');
    } catch (e) {
      debugPrint('[CustomerProfile] delete_my_account error: $e');
      throw _handleException(e);
    }
  }

  String? _avatarUrl(Map<String, dynamic>? metadata) {
    final path = metadata?['avatar_path'] as String?;
    if (path == null || path.isEmpty) return null;
    final version = metadata?['avatar_version'];
    final url = _client.storage.from(_avatarBucket).getPublicUrl(path);
    return version == null ? url : '$url?v=$version';
  }

  CustomerProfileException _handleException(Object error) {
    if (error is CustomerProfileException) return error;

    if (error is AuthException) {
      final code = (error.code ?? '').toLowerCase();
      final message = error.message.toLowerCase();
      debugPrint('[CustomerProfile] AuthException code=$code, msg=${error.message}');

      if (code == 'same_password' || message.contains('different from the old')) {
        return const CustomerProfileException('Password baru harus berbeda dari password lama.');
      }
      if (code == 'weak_password' || message.contains('at least')) {
        return const CustomerProfileException('Password terlalu lemah. Gunakan minimal 6 karakter.');
      }
      if (code == 'email_exists' || message.contains('already been registered')) {
        return const CustomerProfileException('Email sudah digunakan akun lain.');
      }
      if (code == 'phone_exists' ||
          (message.contains('phone') && message.contains('registered'))) {
        return const CustomerProfileException('Nomor telepon sudah digunakan akun lain.');
      }
      if (code == 'otp_expired' ||
          message.contains('expired') ||
          message.contains('invalid')) {
        return const CustomerProfileException('Kode OTP salah atau sudah kedaluwarsa.');
      }
      if (error.statusCode == '429' || code.contains('rate_limit')) {
        return const CustomerProfileException('Terlalu banyak percobaan. Coba lagi beberapa saat.');
      }
      return CustomerProfileException(error.message);
    }

    if (error is StorageException) {
      debugPrint('[CustomerProfile] StorageException status=${error.statusCode}, msg=${error.message}');
      if (error.message.toLowerCase().contains('bucket not found')) {
        return const CustomerProfileException('Penyimpanan foto belum aktif di server. Hubungi admin ServisKu.');
      }
      return CustomerProfileException('Gagal mengunggah foto: ${error.message}');
    }

    if (error is PostgrestException) {
      debugPrint('[CustomerProfile] PostgrestException code=${error.code}, msg=${error.message}');
      final message = error.message.toLowerCase();
      if (message.contains('has_active_orders')) {
        return const CustomerProfileException('Masih ada pesanan yang berjalan. Selesaikan atau batalkan dulu sebelum menghapus akun.');
      }
      if (message.contains('provider_account')) {
        return const CustomerProfileException('Akun penyedia jasa tidak bisa dihapus dari halaman ini.');
      }
      if (error.code == 'PGRST202') {
        return const CustomerProfileException('Fitur ini belum aktif di server. Hubungi admin ServisKu.');
      }
      if (error.code == '42501' || message.contains('permission denied')) {
        return const CustomerProfileException('Anda tidak punya akses untuk aksi ini.');
      }
      return CustomerProfileException(error.message);
    }

    if (error is SocketException ||
        error.toString().toLowerCase().contains('clientexception') ||
        error.toString().toLowerCase().contains('network')) {
      return const CustomerProfileException('Tidak ada koneksi internet. Periksa jaringan Anda.');
    }

    return CustomerProfileException('Terjadi kesalahan: $error');
  }
}
