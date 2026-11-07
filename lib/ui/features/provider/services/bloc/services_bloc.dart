import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servis_ku/ui/features/provider/services/bloc/services_event.dart';
import 'package:servis_ku/ui/features/provider/services/bloc/services_state.dart';
import 'package:servis_ku/ui/features/provider/services/data/services_repository.dart';
import 'package:servis_ku/ui/features/provider/services/domain/service_item.dart';

export 'services_event.dart';
export 'services_state.dart';

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  final ServicesRepository _repository;

  ServicesBloc({required ServicesRepository repository})
      : _repository = repository,
        super(const ServicesInitial()) {
    on<ServicesStarted>(_onStarted);
    on<ServicesCategoryFilterChanged>(_onFilterChanged);
    on<ServiceActiveToggled>(_onActiveToggled);
    on<ServiceCreated>(_onServiceCreated);
    on<ServiceUpdated>(_onServiceUpdated);
    on<ServiceDeleted>(_onServiceDeleted);
  }

  Future<void> _onStarted(
    ServicesStarted event,
    Emitter<ServicesState> emit,
  ) async {
    if (state.services.isEmpty) {
      emit(ServicesLoading(
        services: state.services,
        categories: state.categories,
        selectedCategoryId: state.selectedCategoryId,
      ));
    }
    try {
      final categories = await _repository.getCategories();
      final services = await _repository.getServices();

      emit(ServicesLoaded(
        services: services,
        categories: categories,
        selectedCategoryId: state.selectedCategoryId,
      ));
    } catch (e) {
      emit(ServicesFailure(
        e.toString(),
        services: state.services,
        categories: state.categories,
        selectedCategoryId: state.selectedCategoryId,
      ));
    }
  }

  void _onFilterChanged(
    ServicesCategoryFilterChanged event,
    Emitter<ServicesState> emit,
  ) {
    if (state is ServicesLoaded) {
      final current = state as ServicesLoaded;
      emit(current.copyWith(
        selectedCategoryId: event.categoryId,
        clearCategory: event.categoryId == null,
      ));
    }
  }

  Future<void> _onActiveToggled(
    ServiceActiveToggled event,
    Emitter<ServicesState> emit,
  ) async {
    final currentServices = List<ServiceItem>.from(state.services);
    final index = currentServices.indexWhere((s) => s.id == event.id);
    if (index == -1) return;

    final oldItem = currentServices[index];
    final updatedItem = oldItem.copyWith(isActive: event.value);

    // 1. Optimistic update: langsung ubah di state lokal
    currentServices[index] = updatedItem;
    emit(ServicesLoaded(
      services: currentServices,
      categories: state.categories,
      selectedCategoryId: state.selectedCategoryId,
    ));

    // 2. Kirim update ke backend
    try {
      await _repository.setActive(event.id, event.value);
    } catch (e) {
      // 3. Rollback jika gagal + kirim failure message
      currentServices[index] = oldItem;
      emit(ServicesLoaded(
        services: currentServices,
        categories: state.categories,
        selectedCategoryId: state.selectedCategoryId,
        actionStatus: ServiceActionStatus.failure,
        actionMessage: 'Gagal mengubah status: ${e.toString()}',
      ));
    }
  }

  Future<void> _onServiceCreated(
    ServiceCreated event,
    Emitter<ServicesState> emit,
  ) async {
    if (state is! ServicesLoaded) return;
    final current = state as ServicesLoaded;

    emit(current.copyWith(actionStatus: ServiceActionStatus.saving));
    try {
      await _repository.createService(
        categoryId: event.categoryId,
        name: event.name,
        price: event.price,
        photoFilePath: event.photoFilePath,
      );

      final freshServices = await _repository.getServices();
      emit(current.copyWith(
        services: freshServices,
        actionStatus: ServiceActionStatus.success,
        actionMessage: 'Layanan berhasil ditambahkan',
      ));
    } catch (e) {
      emit(current.copyWith(
        actionStatus: ServiceActionStatus.failure,
        actionMessage: e.toString(),
      ));
    }
  }

  Future<void> _onServiceUpdated(
    ServiceUpdated event,
    Emitter<ServicesState> emit,
  ) async {
    if (state is! ServicesLoaded) return;
    final current = state as ServicesLoaded;

    emit(current.copyWith(actionStatus: ServiceActionStatus.saving));
    try {
      await _repository.updateService(
        id: event.id,
        categoryId: event.categoryId,
        name: event.name,
        price: event.price,
        photoFilePath: event.photoFilePath,
        previousPhotoPath: event.previousPhotoPath,
      );

      final freshServices = await _repository.getServices();
      emit(current.copyWith(
        services: freshServices,
        actionStatus: ServiceActionStatus.success,
        actionMessage: 'Layanan berhasil diperbarui',
      ));
    } catch (e) {
      emit(current.copyWith(
        actionStatus: ServiceActionStatus.failure,
        actionMessage: e.toString(),
      ));
    }
  }

  Future<void> _onServiceDeleted(
    ServiceDeleted event,
    Emitter<ServicesState> emit,
  ) async {
    if (state is! ServicesLoaded) return;
    final current = state as ServicesLoaded;

    emit(current.copyWith(actionStatus: ServiceActionStatus.saving));
    try {
      await _repository.deleteService(event.id);

      final freshServices = await _repository.getServices();
      emit(current.copyWith(
        services: freshServices,
        actionStatus: ServiceActionStatus.success,
        actionMessage: 'Layanan berhasil dihapus',
      ));
    } catch (e) {
      emit(current.copyWith(
        actionStatus: ServiceActionStatus.failure,
        actionMessage: e.toString(),
      ));
    }
  }
}
