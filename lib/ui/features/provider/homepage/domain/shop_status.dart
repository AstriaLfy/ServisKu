import 'package:equatable/equatable.dart';
import '../../profile/domain/shop_profile.dart';

class ShopStatus extends Equatable {
  final String id;
  final String name;
  final String? photoUrl;
  final bool isOnline;
  final VerificationStatus verificationStatus;

  const ShopStatus({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.isOnline,
    required this.verificationStatus,
  });

  bool get isVerified => verificationStatus == VerificationStatus.verified;

  ShopStatus copyWith({
    String? id,
    String? name,
    String? photoUrl,
    bool? isOnline,
    VerificationStatus? verificationStatus,
  }) {
    return ShopStatus(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      isOnline: isOnline ?? this.isOnline,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }

  @override
  List<Object?> get props => [id, name, photoUrl, isOnline, verificationStatus];
}
