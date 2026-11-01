import 'package:equatable/equatable.dart';
import 'package:servis_ku/features/auth/domain/user_role.dart';

class AppUser extends Equatable {
  final String id;
  final String phone;
  final String fullName;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.role,
  });

  factory AppUser.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    return AppUser(
      id: id,
      phone: map['phone'] as String? ?? '',
      fullName: map['full_name'] as String? ?? '',
      role: UserRole.fromString(map['role'] as String?),
    );
  }

  AppUser copyWith({
    String? id,
    String? phone,
    String? fullName,
    UserRole? role,
  }) {
    return AppUser(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [id, phone, fullName, role];
}
