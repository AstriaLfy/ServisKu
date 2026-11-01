import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servis_ku/features/auth/bloc/auth_bloc.dart';
import 'package:servis_ku/ui/features/provider/profile/bloc/shop_profile_event.dart';
import 'package:servis_ku/ui/features/provider/profile/bloc/shop_profile_state.dart';
import 'package:servis_ku/ui/features/provider/profile/data/shop_profile_repository.dart';

export 'shop_profile_event.dart';
export 'shop_profile_state.dart';

class ShopProfileBloc extends Bloc<ShopProfileEvent, ShopProfileState> {
  final ShopProfileRepository _repository;
  final AuthBloc? _authBloc;

  ShopProfileBloc({
    required ShopProfileRepository repository,
    AuthBloc? authBloc,
  })  : _repository = repository,
        _authBloc = authBloc,
        super(const ShopProfileInitial()) {
    on<ShopProfileStarted>(_onStarted);
    on<ShopInfoUpdated>(_onShopInfoUpdated);
    on<ShopPhotoPicked>(_onShopPhotoPicked);
    on<OperatingHoursUpdated>(_onOperatingHoursUpdated);
  }

  Future<void> _onStarted(
    ShopProfileStarted event,
    Emitter<ShopProfileState> emit,
  ) async {
    // Jika belum ada data toko, tampilkan loading penuh
    if (state.shop == null) {
      emit(const ShopProfileLoading());
    }
    try {
      final shop = await _repository.getMyShop();
      emit(ShopProfileLoaded(shop));
    } catch (e) {
      emit(ShopProfileFailure(e.toString(), shop: state.shop));
    }
  }

  Future<void> _onShopInfoUpdated(
    ShopInfoUpdated event,
    Emitter<ShopProfileState> emit,
  ) async {
    final currentShop = state.shop;
    if (currentShop == null) return;

    emit(ShopProfileSaving(currentShop));
    try {
      await _repository.updateShopInfo(
        shopId: currentShop.id,
        name: event.name,
        tagline: event.tagline,
        serviceArea: event.serviceArea,
      );

      // Trigger di database otomatis update profiles.full_name jika nama berubah
      if (event.name != null && event.name!.trim().isNotEmpty) {
        _authBloc?.add(UserProfileRefreshed(newFullName: event.name!.trim()));
      }

      final updatedShop = await _repository.getMyShop();
      emit(ShopProfileSuccess(updatedShop, message: 'Profil toko berhasil diperbarui'));
    } catch (e) {
      emit(ShopProfileFailure(e.toString(), shop: currentShop));
    }
  }

  Future<void> _onShopPhotoPicked(
    ShopPhotoPicked event,
    Emitter<ShopProfileState> emit,
  ) async {
    final currentShop = state.shop;
    if (currentShop == null) return;

    emit(ShopProfileSaving(currentShop));
    try {
      final newPhotoUrl = await _repository.uploadShopPhoto(
        shopId: currentShop.id,
        imageFile: event.imageFile,
      );

      final updatedShop = currentShop.copyWith(photoUrl: newPhotoUrl);
      emit(ShopProfileSuccess(updatedShop, message: 'Foto toko berhasil diperbarui'));
    } catch (e) {
      emit(ShopProfileFailure(e.toString(), shop: currentShop));
    }
  }

  Future<void> _onOperatingHoursUpdated(
    OperatingHoursUpdated event,
    Emitter<ShopProfileState> emit,
  ) async {
    final currentShop = state.shop;
    if (currentShop == null) return;

    emit(ShopProfileSaving(currentShop));
    try {
      await _repository.updateOperatingHours(
        shopId: currentShop.id,
        hours: event.hours,
      );

      final updatedShop = await _repository.getMyShop();
      emit(ShopProfileSuccess(updatedShop, message: 'Jam operasional berhasil disimpan'));
    } catch (e) {
      emit(ShopProfileFailure(e.toString(), shop: currentShop));
    }
  }
}
