import 'package:equatable/equatable.dart';

class CustomerAddress extends Equatable {
  final String id;
  final String label;
  final String region;
  final String detail;
  final String? extraDetail;
  final String? phone;
  final String? mapLocation;

  const CustomerAddress({
    required this.id,
    required this.label,
    required this.region,
    required this.detail,
    this.extraDetail,
    this.phone,
    this.mapLocation,
  });

  String get fullAddress => [detail, extraDetail, region]
      .whereType<String>()
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .join(', ');

  factory CustomerAddress.fromMap(Map<String, dynamic> map) {
    return CustomerAddress(
      id: map['id']?.toString() ?? '',
      label: map['label'] as String? ?? 'Alamat',
      region: map['region'] as String? ?? '',
      detail: map['detail'] as String? ?? '',
      extraDetail: map['extra_detail'] as String?,
      phone: map['phone'] as String?,
      mapLocation: map['map_location'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'region': region,
      'detail': detail,
      'extra_detail': extraDetail,
      'phone': phone,
      'map_location': mapLocation,
    };
  }

  CustomerAddress copyWith({
    String? label,
    String? region,
    String? detail,
    String? extraDetail,
    String? phone,
    String? mapLocation,
  }) {
    return CustomerAddress(
      id: id,
      label: label ?? this.label,
      region: region ?? this.region,
      detail: detail ?? this.detail,
      extraDetail: extraDetail ?? this.extraDetail,
      phone: phone ?? this.phone,
      mapLocation: mapLocation ?? this.mapLocation,
    );
  }

  @override
  List<Object?> get props => [id, label, region, detail, extraDetail, phone, mapLocation];
}

class AddressBook extends Equatable {
  final List<CustomerAddress> addresses;
  final String? selectedId;

  const AddressBook({this.addresses = const [], this.selectedId});

  CustomerAddress? get selectedAddress =>
      addresses.where((address) => address.id == selectedId).firstOrNull ??
      addresses.firstOrNull;

  @override
  List<Object?> get props => [addresses, selectedId];
}
