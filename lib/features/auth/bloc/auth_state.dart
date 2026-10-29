part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

/// OTP berhasil dikirim (hanya untuk alur register)
class OtpSent extends AuthState {
  final String phone;
  final AuthMode mode;

  const OtpSent({required this.phone, required this.mode});

  @override
  List<Object?> get props => [phone, mode];
}

/// OTP diverifikasi, user perlu isi nama & role
class ProfileSetupRequired extends AuthState {
  const ProfileSetupRequired();
}

/// Login/register selesai sepenuhnya
class AuthSuccess extends AuthState {
  final AppUser user;
  final String? notice;

  const AuthSuccess({required this.user, this.notice});

  @override
  List<Object?> get props => [user, notice];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthFailure extends AuthState {
  final err.AuthFailure failure;
  final String message;

  const AuthFailure(this.failure, this.message);

  @override
  List<Object?> get props => [failure, message];
}
