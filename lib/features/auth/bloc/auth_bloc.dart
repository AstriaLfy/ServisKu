import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:servis_ku/core/errors/auth_failure.dart' as err;
import 'package:servis_ku/core/errors/auth_failure.dart' show AuthFailureException;
import 'package:servis_ku/core/utils/phone_formatter.dart';
import 'package:servis_ku/features/auth/data/auth_repository.dart';
import 'package:servis_ku/features/auth/domain/app_user.dart';
import 'package:servis_ku/features/auth/domain/auth_mode.dart';
import 'package:servis_ku/features/auth/domain/user_role.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  // Simpan data sesi registrasi untuk resend OTP
  String? _lastPhone;
  String? _lastPassword;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<RegisterWithPasswordRequested>(_onRegisterWithPasswordRequested);
    on<LoginWithPasswordRequested>(_onLoginWithPasswordRequested);
    on<OtpResendRequested>(_onOtpResendRequested);
    on<OtpVerified>(_onOtpVerified);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthSuccess(user: user));
      } else {
        emit(const Unauthenticated());
      }
    } on AuthFailureException catch (_) {
      emit(const Unauthenticated());
    } catch (_) {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onRegisterWithPasswordRequested(
    RegisterWithPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    final formattedPhone = PhoneFormatter.format(event.phone);
    if (formattedPhone == null) {
      emit(AuthFailure(
        err.AuthFailure.invalidPhone,
        err.AuthFailure.invalidPhone.userMessage,
      ));
      return;
    }

    if (event.password.length < 6) {
      emit(const AuthFailure(
        err.AuthFailure.unknown,
        'Password minimal 6 karakter.',
      ));
      return;
    }

    _lastPhone = formattedPhone;
    _lastPassword = event.password;

    emit(const AuthLoading());
    try {
      await _authRepository.registerWithPassword(
        phone: formattedPhone,
        password: event.password,
      );
      emit(OtpSent(phone: formattedPhone, mode: AuthMode.register));
    } on AuthFailureException catch (e) {
      emit(AuthFailure(e.failure, e.message));
    } catch (_) {
      emit(AuthFailure(err.AuthFailure.unknown, err.AuthFailure.unknown.userMessage));
    }
  }

  Future<void> _onLoginWithPasswordRequested(
    LoginWithPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    final formattedPhone = PhoneFormatter.format(event.phone);
    if (formattedPhone == null) {
      emit(AuthFailure(
        err.AuthFailure.invalidPhone,
        err.AuthFailure.invalidPhone.userMessage,
      ));
      return;
    }

    emit(const AuthLoading());
    try {
      final user = await _authRepository.loginWithPassword(
        phone: formattedPhone,
        password: event.password,
      );
      emit(AuthSuccess(user: user));
    } on AuthFailureException catch (e) {
      emit(AuthFailure(e.failure, e.message));
    } catch (_) {
      emit(AuthFailure(err.AuthFailure.unknown, err.AuthFailure.unknown.userMessage));
    }
  }

  Future<void> _onOtpResendRequested(
    OtpResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_lastPhone == null || _lastPassword == null) {
      emit(const AuthFailure(
        err.AuthFailure.unknown,
        'Data sesi tidak ditemukan. Silakan ulangi pendaftaran.',
      ));
      return;
    }

    emit(const AuthLoading());
    try {
      await _authRepository.registerWithPassword(
        phone: _lastPhone!,
        password: _lastPassword!,
      );
      emit(OtpSent(phone: _lastPhone!, mode: AuthMode.register));
    } on AuthFailureException catch (e) {
      emit(AuthFailure(e.failure, e.message));
    } catch (_) {
      emit(AuthFailure(err.AuthFailure.unknown, err.AuthFailure.unknown.userMessage));
    }
  }

  Future<void> _onOtpVerified(
    OtpVerified event,
    Emitter<AuthState> emit,
  ) async {
    if (_lastPhone == null) {
      emit(const AuthFailure(
        err.AuthFailure.unknown,
        'Nomor telepon tidak ditemukan. Silakan ulangi pendaftaran.',
      ));
      return;
    }

    emit(const AuthLoading());
    try {
      await _authRepository.verifyRegistrationOtp(
        phone: _lastPhone!,
        token: event.token.trim(),
      );
      // OTP berhasil → user perlu isi nama & role
      emit(const ProfileSetupRequired());
    } on AuthFailureException catch (e) {
      emit(AuthFailure(e.failure, e.message));
    } catch (_) {
      emit(AuthFailure(err.AuthFailure.unknown, err.AuthFailure.unknown.userMessage));
    }
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.updateUserProfile(
        fullName: event.fullName,
        role: event.role,
      );
      emit(AuthSuccess(user: user));
    } on AuthFailureException catch (e) {
      emit(AuthFailure(e.failure, e.message));
    } catch (_) {
      emit(AuthFailure(err.AuthFailure.unknown, err.AuthFailure.unknown.userMessage));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signOut();
      _lastPhone = null;
      _lastPassword = null;
      emit(const Unauthenticated());
    } on AuthFailureException catch (e) {
      emit(AuthFailure(e.failure, e.message));
    } catch (_) {
      emit(AuthFailure(err.AuthFailure.unknown, err.AuthFailure.unknown.userMessage));
    }
  }
}
