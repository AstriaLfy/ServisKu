import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servis_ku/core/utils/phone_formatter.dart';
import 'package:servis_ku/ui/features/customer/profile/data/customer_profile_repository.dart';
import 'package:servis_ku/ui/features/customer/profile/domain/customer_profile.dart';
import 'customer_profile_state.dart';

class CustomerProfileCubit extends Cubit<CustomerProfileState> {
  final CustomerProfileRepository _repository;

  CustomerProfileCubit({CustomerProfileRepository? repository})
      : _repository = repository ?? CustomerProfileRepository(),
        super(const CustomerProfileState());

  Future<void> load() async {
    if (state.status != ProfileStatus.loaded) {
      emit(state.copyWith(status: ProfileStatus.loading, clearError: true));
    }

    try {
      final profile = await _repository.getProfile();
      emit(state.copyWith(status: ProfileStatus.loaded, profile: profile, clearError: true));
    } catch (e) {
      emit(state.copyWith(
        status: state.status == ProfileStatus.loaded
            ? ProfileStatus.loaded
            : ProfileStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<bool> uploadAvatar(String filePath) async {
    if (state.isUploadingAvatar) return false;
    emit(state.copyWith(isUploadingAvatar: true, clearError: true));

    try {
      final url = await _repository.uploadAvatar(filePath);
      emit(state.copyWith(
        isUploadingAvatar: false,
        profile: state.profile.copyWith(avatarUrl: url),
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(isUploadingAvatar: false, errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> deleteAccount() {
    return _run(_repository.deleteAccount, (profile) => profile);
  }

  Future<bool> updateField(ProfileField field, String value) {
    final text = value.trim();
    switch (field) {
      case ProfileField.name:
        return _run(
          () => _repository.updateName(text),
          (profile) => profile.copyWith(fullName: text),
        );
      case ProfileField.bio:
        return _run(
          () => _repository.updateBio(text),
          (profile) => profile.copyWith(bio: text),
        );
      case ProfileField.email:
        return _run(() => _repository.updateEmail(text), (profile) => profile);
      case ProfileField.phone:
        final phone = PhoneFormatter.format(text) ?? text;
        return _run(() => _repository.requestPhoneChange(phone), (profile) => profile);
    }
  }

  Future<bool> verifyPhone({required String phone, required String token}) {
    return _run(
      () => _repository.verifyPhoneChange(phone: phone, token: token),
      (profile) => profile.copyWith(phone: phone),
    );
  }

  Future<bool> resendPhoneOtp(String phone) {
    return _run(() => _repository.requestPhoneChange(phone), (profile) => profile);
  }

  Future<bool> updatePassword(String password) {
    return _run(() => _repository.updatePassword(password), (profile) => profile);
  }

  void reset() => emit(const CustomerProfileState());

  Future<bool> _run(
    Future<void> Function() action,
    CustomerProfile Function(CustomerProfile profile) onSuccess,
  ) async {
    if (state.isSaving) return false;
    emit(state.copyWith(isSaving: true, clearError: true));

    try {
      await action();
      emit(state.copyWith(isSaving: false, profile: onSuccess(state.profile)));
      return true;
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
      return false;
    }
  }
}
