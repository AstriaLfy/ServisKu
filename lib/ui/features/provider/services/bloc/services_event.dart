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

  const ServiceCreated({
    required this.categoryId,
    required this.name,
    required this.price,
  });

  @override
  List<Object?> get props => [categoryId, name, price];
}

/// Update layanan yang ada
class ServiceUpdated extends ServicesEvent {
  final String id;
  final int categoryId;
  final String name;
  final int price;

  const ServiceUpdated({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
  });

  @override
  List<Object?> get props => [id, categoryId, name, price];
}

/// Hapus layanan (soft delete)
class ServiceDeleted extends ServicesEvent {
  final String id;

  const ServiceDeleted(this.id);

  @override
  List<Object?> get props => [id];
}
