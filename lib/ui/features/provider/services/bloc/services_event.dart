import 'package:equatable/equatable.dart';

sealed class ServicesEvent extends Equatable {
  const ServicesEvent();

  @override
  List<Object?> get props => [];
}

/// Ambil kategori dan layanan pertama kali atau refresh
class ServicesStarted extends ServicesEvent {
  const ServicesStarted();
}

/// Filter kategori diubah (null = 'Semua')
class ServicesCategoryFilterChanged extends ServicesEvent {
  final int? categoryId;

  const ServicesCategoryFilterChanged(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Toggle switch status aktif / nonaktif layanan (optimistic update)
class ServiceActiveToggled extends ServicesEvent {
  final String id;
  final bool value;

  const ServiceActiveToggled({
    required this.id,
    required this.value,
  });

  @override
  List<Object?> get props => [id, value];
}

/// Tambah layanan baru
class ServiceCreated extends ServicesEvent {
  final int categoryId;
  final String name;
  final int price;
  final String? photoFilePath;

  const ServiceCreated({
    required this.categoryId,
    required this.name,
    required this.price,
    this.photoFilePath,
  });

  @override
  List<Object?> get props => [categoryId, name, price, photoFilePath];
}

/// Update layanan yang ada
class ServiceUpdated extends ServicesEvent {
  final String id;
  final int categoryId;
  final String name;
  final int price;
  final String? photoFilePath;
  final String? previousPhotoPath;

  const ServiceUpdated({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    this.photoFilePath,
    this.previousPhotoPath,
  });

  @override
  List<Object?> get props => [id, categoryId, name, price, photoFilePath, previousPhotoPath];
}

/// Hapus layanan (soft delete)
class ServiceDeleted extends ServicesEvent {
  final String id;

  const ServiceDeleted(this.id);

  @override
  List<Object?> get props => [id];
}
