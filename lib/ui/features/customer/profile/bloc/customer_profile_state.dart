import 'package:equatable/equatable.dart';
import 'package:servis_ku/ui/features/customer/profile/domain/customer_profile.dart';

enum ProfileStatus { initial, loading, loaded, failure }

class CustomerProfileState extends Equatable {
  final ProfileStatus status;
  final CustomerProfile profile;
  final bool isUploadingAvatar;
  final bool isSaving;
  final String? errorMessage;

  const CustomerProfileState({
    this.status = ProfileStatus.initial,
    this.profile = const CustomerProfile(),
    this.isUploadingAvatar = false,
    this.isSaving = false,
    this.errorMessage,
  });

  CustomerProfileState copyWith({
    ProfileStatus? status,
    CustomerProfile? profile,
    bool? isUploadingAvatar,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CustomerProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, profile, isUploadingAvatar, isSaving, errorMessage];
}
