import 'package:equatable/equatable.dart';
import 'package:servis_ku/ui/features/provider/profile/domain/shop_profile.dart';

enum ShopProfileActionStatus { idle, saving, success, failure }

sealed class ShopProfileState extends Equatable {
  final ShopProfile? shop;
  const ShopProfileState({this.shop});

  @override
  List<Object?> get props => [shop];
}

class ShopProfileInitial extends ShopProfileState {
  const ShopProfileInitial() : super(shop: null);
}

class ShopProfileLoading extends ShopProfileState {
  const ShopProfileLoading() : super(shop: null);
}

class ShopProfileLoaded extends ShopProfileState {
  const ShopProfileLoaded(ShopProfile shop) : super(shop: shop);

  @override
  ShopProfile get shop => super.shop!;
}

class ShopProfileSaving extends ShopProfileState {
  const ShopProfileSaving(ShopProfile shop) : super(shop: shop);

  @override
  ShopProfile get shop => super.shop!;
}

class ShopProfileSuccess extends ShopProfileState {
  final String message;
  const ShopProfileSuccess(ShopProfile shop, {required this.message})
      : super(shop: shop);

  @override
  ShopProfile get shop => super.shop!;

  @override
  List<Object?> get props => [shop, message];
}

class ShopProfileFailure extends ShopProfileState {
  final String message;

  const ShopProfileFailure(this.message, {ShopProfile? shop})
      : super(shop: shop);

  @override
  List<Object?> get props => [message, shop];
}
