import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:servis_ku/core/utils/phone_formatter.dart';

class CustomerProfile extends Equatable {
  final String fullName;
  final String phone;
  final String email;
  final String bio;
  final String? avatarUrl;

  const CustomerProfile({
    this.fullName = '',
    this.phone = '',
    this.email = '',
    this.bio = '',
    this.avatarUrl,
  });

  CustomerProfile copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? bio,
    String? avatarUrl,
  }) {
    return CustomerProfile(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [fullName, phone, email, bio, avatarUrl];
}

enum ProfileField {
  name('name', 'Ubah Nama', 'Nama', 'Masukkan nama lengkap', TextInputType.name),
  bio('bio', 'Ubah Bio', 'Bio', 'Ceritakan sedikit tentang dirimu', TextInputType.text),
  email('email', 'Ubah Email', 'Email', 'contoh@email.com', TextInputType.emailAddress),
  phone('phone', 'Ubah Nomor Telepon', 'Nomor Telepon', '08xxxxxxxxxx', TextInputType.phone);

  final String path;
  final String title;
  final String label;
  final String hint;
  final TextInputType keyboardType;

  const ProfileField(this.path, this.title, this.label, this.hint, this.keyboardType);

  static ProfileField fromPath(String? path) =>
      ProfileField.values.where((field) => field.path == path).firstOrNull ?? ProfileField.name;

  String valueOf(CustomerProfile profile) {
    switch (this) {
      case ProfileField.name:
        return profile.fullName;
      case ProfileField.bio:
        return profile.bio;
      case ProfileField.email:
        return profile.email;
      case ProfileField.phone:
        return profile.phone;
    }
  }

  String? validate(String? value) {
    final text = value?.trim() ?? '';
    switch (this) {
      case ProfileField.name:
        if (text.isEmpty) return 'Nama tidak boleh kosong';
        if (text.length < 3) return 'Nama minimal 3 karakter';
        return null;
      case ProfileField.bio:
        if (text.length > 150) return 'Bio maksimal 150 karakter';
        return null;
      case ProfileField.email:
        if (text.isEmpty) return 'Email tidak boleh kosong';
        final valid = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch(text);
        return valid ? null : 'Format email tidak valid';
      case ProfileField.phone:
        if (text.isEmpty) return 'Nomor telepon tidak boleh kosong';
        return PhoneFormatter.format(text) == null ? 'Format nomor telepon tidak valid' : null;
    }
  }
}

String formatDisplayPhone(String phone) {
  final normalized = PhoneFormatter.format(phone);
  if (normalized == null) return phone;
  final digits = normalized.substring(3);
  final groups = <String>[digits.substring(0, 3)];
  for (var i = 3; i < digits.length; i += 4) {
    groups.add(digits.substring(i, min(i + 4, digits.length)));
  }
  return '+62-${groups.join('-')}';
}
