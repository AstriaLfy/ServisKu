import 'package:equatable/equatable.dart';
import 'package:servis_ku/ui/features/provider/services/domain/service_item.dart';

enum ServiceActionStatus { idle, saving, success, failure }

sealed class ServicesState extends Equatable {
  final List<ServiceItem> services;
  final List<ServiceCategory> categories;
  final int? selectedCategoryId; // null = 'Semua'
  final ServiceActionStatus actionStatus;
  final String? actionMessage;

  const ServicesState({
    this.services = const [],
    this.categories = const [],
    this.selectedCategoryId,
    this.actionStatus = ServiceActionStatus.idle,
    this.actionMessage,
  });

  /// Daftar layanan yang sudah difilter berdasarkan selectedCategoryId
  List<ServiceItem> get filteredServices {
    if (selectedCategoryId == null) return services;
    return services.where((s) => s.categoryId == selectedCategoryId).toList();
  }

  /// Nama kategori yang sedang dipilih (null jika 'Semua')
  String? get selectedCategoryName {
    if (selectedCategoryId == null) return null;
    final cat = categories.where((c) => c.id == selectedCategoryId).firstOrNull;
    return cat?.name;
  }

  @override
  List<Object?> get props => [
        services,
        categories,
        selectedCategoryId,
        actionStatus,
        actionMessage,
      ];
}

class ServicesInitial extends ServicesState {
  const ServicesInitial();
}

class ServicesLoading extends ServicesState {
  const ServicesLoading({
    super.services,
    super.categories,
    super.selectedCategoryId,
  });
}

class ServicesLoaded extends ServicesState {
  const ServicesLoaded({
    required super.services,
    required super.categories,
    super.selectedCategoryId,
    super.actionStatus = ServiceActionStatus.idle,
    super.actionMessage,
  });

  ServicesLoaded copyWith({
    List<ServiceItem>? services,
    List<ServiceCategory>? categories,
    int? selectedCategoryId,
    bool clearCategory = false,
    ServiceActionStatus? actionStatus,
    String? actionMessage,
  }) {
    return ServicesLoaded(
      services: services ?? this.services,
      categories: categories ?? this.categories,
      selectedCategoryId:
          clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage,
    );
  }
}

class ServicesFailure extends ServicesState {
  final String message;

  const ServicesFailure(
    this.message, {
    super.services,
    super.categories,
    super.selectedCategoryId,
  });

  @override
  List<Object?> get props => [
        message,
        services,
        categories,
        selectedCategoryId,
      ];
}
