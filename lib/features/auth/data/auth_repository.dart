import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:servis_ku/core/errors/auth_failure.dart';
import 'package:servis_ku/core/services/supabase_service.dart';
import 'package:servis_ku/features/auth/domain/app_user.dart';
import 'package:servis_ku/features/auth/domain/user_role.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  // ─── Register: phone + password → kirim OTP ────────────────────────────────

  Future<void> registerWithPassword({
    required String phone,
    required String password,
  }) async {
    try {
      debugPrint('[Auth] registerWithPassword: phone=$phone');
      await _client.auth.signUp(phone: phone, password: password);
    } catch (e) {
      debugPrint('[Auth] registerWithPassword error: $e');
      throw _handleException(e);
    }
  }

  // ─── Login: phone + password → langsung masuk, tanpa OTP ───────────────────

  Future<AppUser> loginWithPassword({
    required String phone,
    required String password,
  }) async {
    try {
      debugPrint('[Auth] loginWithPassword: phone=$phone');
      final res = await _client.auth.signInWithPassword(
        phone: phone,
        password: password,
      );

      final user = res.user ?? _client.auth.currentUser;
      if (user == null) {
        throw const AuthFailureException(
          failure: AuthFailure.unknown,
          message: 'Gagal mendapatkan sesi setelah login.',
        );
      }

      return await _readProfile(user.id);
    } catch (e) {
      debugPrint('[Auth] loginWithPassword error: $e');
      if (e is AuthFailureException) rethrow;
      throw _handleException(e);
    }
  }

  // ─── Verifikasi OTP saat registrasi ────────────────────────────────────────

  Future<void> verifyRegistrationOtp({
    required String phone,
    required String token,
  }) async {
    try {
      debugPrint('[Auth] verifyRegistrationOtp: phone=$phone');
      await _client.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );
      debugPrint('[Auth] OTP terverifikasi, sesi aktif.');
    } catch (e) {
      debugPrint('[Auth] verifyRegistrationOtp error: $e');
      if (e is AuthFailureException) rethrow;
      throw _handleException(e);
    }
  }

  // ─── Simpan nama + role ke profil setelah OTP diverifikasi ─────────────────

  Future<AppUser> updateUserProfile({
    required String fullName,
    required UserRole role,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const AuthFailureException(
          failure: AuthFailure.unknown,
          message: 'Sesi tidak ditemukan, silakan login ulang.',
        );
      }

      debugPrint('[Auth] updateUserProfile: userId=${user.id}, fullName=$fullName, role=${role.name}');

      // 1. Update metadata di auth.users (trigger di DB akan update profiles jika ada)
      await _client.auth.updateUser(
        UserAttributes(data: {'full_name': fullName, 'role': role.name}),
      );

      // 2. Update profiles langsung (diperlukan karena trigger hanya pada INSERT)
      await _client.from('profiles').update({
        'full_name': fullName,
        'role': role.name,
      }).eq('id', user.id);

      return await _readProfile(user.id);
    } catch (e) {
      debugPrint('[Auth] updateUserProfile error: $e');
      if (e is AuthFailureException) rethrow;
      throw _handleException(e);
    }
  }

  // ─── Baca profil user aktif ─────────────────────────────────────────────────

  Future<AppUser?> getCurrentUser() async {
    try {
      final session = _client.auth.currentSession;
      final user = _client.auth.currentUser;
      if (session == null || user == null) return null;

      debugPrint('[Auth] getCurrentUser: userId=${user.id}');
      final profile = await _client
          .from('profiles')
          .select('phone, full_name, role')
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        debugPrint('[Auth] Profil tidak ditemukan, signOut.');
        await signOut();
        throw const AuthFailureException(
          failure: AuthFailure.profileNotFound,
          message: 'Data akun tidak ditemukan, hubungi admin.',
        );
      }

      return AppUser.fromMap(id: user.id, map: profile);
    } catch (e) {
      debugPrint('[Auth] getCurrentUser error: $e');
      if (e is AuthFailureException) rethrow;
      throw _handleException(e);
    }
  }

  // ─── Sign out ───────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('[Auth] signOut error: $e');
      throw _handleException(e);
    }
  }

  // ─── Helper internal: baca profil dari tabel profiles ──────────────────────

  Future<AppUser> _readProfile(String userId) async {
    final profile = await _client
        .from('profiles')
        .select('phone, full_name, role')
        .eq('id', userId)
        .maybeSingle();

    if (profile == null) {
      debugPrint('[Auth] _readProfile: profil tidak ditemukan untuk user $userId');
      throw const AuthFailureException(
        failure: AuthFailure.profileNotFound,
        message: 'Data akun tidak ditemukan, hubungi admin.',
      );
    }

    return AppUser.fromMap(id: userId, map: profile);
  }

  // ─── Mapping error Supabase → AuthFailureException ─────────────────────────

  AuthFailureException _handleException(dynamic error) {
    if (error is AuthException) {
      final statusCode = error.statusCode ?? '';
      final code = (error.code ?? '').toLowerCase();
      final message = error.message.toLowerCase();

      debugPrint('[Auth] AuthException status=$statusCode, code=$code, msg=${error.message}');

      if (message.contains('invalid login credentials') ||
          code == 'invalid_credentials') {
        return const AuthFailureException(
          failure: AuthFailure.invalidCredentials,
          message: 'Nomor telepon atau password salah.',
        );
      }

      if (message.contains('user already registered') ||
          code == 'user_already_exists') {
        return const AuthFailureException(
          failure: AuthFailure.phoneAlreadyRegistered,
          message: 'Nomor sudah terdaftar. Silakan login.',
        );
      }

      if (message.contains('signups not allowed') ||
          code == 'signup_disabled') {
        return const AuthFailureException(
          failure: AuthFailure.phoneNotRegistered,
          message: 'Registrasi tidak tersedia saat ini.',
        );
      }

      if (statusCode == '429' || code == 'over_sms_send_rate_limit') {
        return AuthFailureException(
          failure: AuthFailure.rateLimited,
          message: AuthFailure.rateLimited.userMessage,
        );
      }

      if (code == 'otp_expired' || message.contains('expired')) {
        return AuthFailureException(
          failure: AuthFailure.expiredOtp,
          message: AuthFailure.expiredOtp.userMessage,
        );
      }

      if (code == 'invalid_grant' ||
          code == 'otp_invalid' ||
          message.contains('token has expired or is invalid') ||
          message.contains('invalid otp')) {
        return AuthFailureException(
          failure: AuthFailure.invalidOtp,
          message: AuthFailure.invalidOtp.userMessage,
        );
      }

      if (code == 'validation_failed' ||
          (message.contains('phone') &&
              (message.contains('format') || message.contains('invalid')))) {
        return AuthFailureException(
          failure: AuthFailure.invalidPhone,
          message: AuthFailure.invalidPhone.userMessage,
        );
      }

      return AuthFailureException(
        failure: AuthFailure.unknown,
        message: error.message.isNotEmpty ? error.message : AuthFailure.unknown.userMessage,
      );
    }

    if (error is SocketException ||
        error.toString().toLowerCase().contains('clientexception') ||
        error.toString().toLowerCase().contains('network')) {
      return AuthFailureException(
        failure: AuthFailure.network,
        message: AuthFailure.network.userMessage,
      );
    }

    return AuthFailureException(
      failure: AuthFailure.unknown,
      message: AuthFailure.unknown.userMessage,
    );
  }
}
