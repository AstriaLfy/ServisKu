enum AuthFailure {
  invalidPhone,
  invalidCredentials,
  invalidOtp,
  expiredOtp,
  rateLimited,
  smsProviderError,
  phoneNotRegistered,
  phoneAlreadyRegistered,
  profileNotFound,
  network,
  unknown;

  String get userMessage {
    switch (this) {
      case AuthFailure.invalidPhone:
        return 'Format nomor telepon tidak valid. Gunakan format 08xx atau +628xx.';
      case AuthFailure.invalidCredentials:
        return 'Nomor telepon atau password salah.';
      case AuthFailure.invalidOtp:
        return 'Kode OTP salah, coba lagi.';
      case AuthFailure.expiredOtp:
        return 'Kode OTP sudah kedaluwarsa, silakan kirim ulang.';
      case AuthFailure.rateLimited:
        return 'Terlalu banyak permintaan, coba lagi beberapa menit lagi.';
      case AuthFailure.smsProviderError:
        return 'Gagal mengirim SMS OTP, silakan coba lagi nanti.';
      case AuthFailure.phoneNotRegistered:
        return 'Nomor belum terdaftar, silakan daftar terlebih dahulu.';
      case AuthFailure.phoneAlreadyRegistered:
        return 'Nomor sudah terdaftar. Silakan login.';
      case AuthFailure.profileNotFound:
        return 'Data akun tidak ditemukan, hubungi admin.';
      case AuthFailure.network:
        return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
      case AuthFailure.unknown:
        return 'Terjadi kesalahan sistem, silakan coba lagi.';
    }
  }
}

typedef AuthFailureType = AuthFailure;

class AuthFailureException implements Exception {
  final AuthFailure failure;
  final String message;

  const AuthFailureException({
    required this.failure,
    required this.message,
  });

  @override
  String toString() => 'AuthFailureException(failure: $failure, message: $message)';
}
