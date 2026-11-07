import 'package:equatable/equatable.dart';
import 'package:servis_ku/ui/features/customer/shop/domain/shop_summary.dart';
import 'package:servis_ku/ui/features/provider/services/domain/service_item.dart';

enum CustomerHomeStatus { initial, loading, loaded, failure }

class CustomerHomeState extends Equatable {
  final CustomerHomeStatus status;
  final List<ServiceCategory> categories;
  final List<ShopSummary> shops;
  final int? selectedCategoryId;
  final bool isLoadingShops;
  final String? errorMessage;

  const CustomerHomeState({
    this.status = CustomerHomeStatus.initial,
    this.categories = const [],
    this.shops = const [],
    this.selectedCategoryId,
    this.isLoadingShops = false,
    this.errorMessage,
  });

  CustomerHomeState copyWith({
    CustomerHomeStatus? status,
    List<ServiceCategory>? categories,
    List<ShopSummary>? shops,
    int? selectedCategoryId,
    bool clearCategory = false,
    bool? isLoadingShops,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CustomerHomeState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      shops: shops ?? this.shops,
      selectedCategoryId:
          clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      isLoadingShops: isLoadingShops ?? this.isLoadingShops,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        shops,
        selectedCategoryId,
        isLoadingShops,
        errorMessage,
      ];
}
