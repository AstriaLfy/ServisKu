import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:servis_ku/ui/features/provider/profile/domain/shop_profile.dart';

sealed class ShopProfileEvent extends Equatable {
  const ShopProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Ambil / refresh profil toko dari database
class ShopProfileStarted extends ShopProfileEvent {
  const ShopProfileStarted();
}

/// Update info dasar: nama toko, tagline, area layanan
class ShopInfoUpdated extends ShopProfileEvent {
  final String? name;
  final String? tagline;
  final String? serviceArea;

  const ShopInfoUpdated({
    this.name,
    this.tagline,
    this.serviceArea,
  });

  @override
  List<Object?> get props => [name, tagline, serviceArea];
}

/// Upload foto toko baru
class ShopPhotoPicked extends ShopProfileEvent {
  final File imageFile;

  const ShopPhotoPicked(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

/// Update jam operasional toko
class OperatingHoursUpdated extends ShopProfileEvent {
  final List<OperatingHour> hours;

  const OperatingHoursUpdated(this.hours);

  @override
  List<Object?> get props => [hours];
}
