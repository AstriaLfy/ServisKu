part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Cek status sesi saat app dibuka
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Registrasi dengan nomor HP + password → mengirim OTP ke HP
class RegisterWithPasswordRequested extends AuthEvent {
  final String phone;
  final String password;

  const RegisterWithPasswordRequested({
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [phone, password];
}

/// Login dengan nomor HP + password (tanpa OTP)
class LoginWithPasswordRequested extends AuthEvent {
  final String phone;
  final String password;

  const LoginWithPasswordRequested({
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [phone, password];
}

/// Kirim ulang OTP saat registrasi
class OtpResendRequested extends AuthEvent {
  const OtpResendRequested();
}

/// Verifikasi kode OTP 6 digit saat registrasi
class OtpVerified extends AuthEvent {
  final String token;

  const OtpVerified(this.token);

  @override
  List<Object?> get props => [token];
}

/// Simpan nama + role ke profil setelah OTP diverifikasi
class ProfileUpdateRequested extends AuthEvent {
  final String fullName;
  final UserRole role;

  const ProfileUpdateRequested({
    required this.fullName,
    required this.role,
  });

  @override
  List<Object?> get props => [fullName, role];
}

/// Keluar dari sesi aplikasi
class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}
