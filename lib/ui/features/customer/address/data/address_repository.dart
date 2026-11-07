import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:servis_ku/core/services/supabase_service.dart';
import 'package:servis_ku/ui/features/customer/address/domain/customer_address.dart';

class AddressException implements Exception {
  final String message;
  const AddressException(this.message);

  @override
  String toString() => message;
}

class AddressRepository {
  final SupabaseClient _client;

  AddressRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  static const String _addressesKey = 'addresses';
  static const String _selectedKey = 'selected_address_id';

  Future<AddressBook> getAddressBook() async {
    try {
      debugPrint('[Address] getAddressBook');
      final response = await _client.auth.getUser();
      return _parse(response.user?.userMetadata);
    } catch (e) {
      debugPrint('[Address] getAddressBook error: $e');
      final cached = _client.auth.currentUser;
      if (cached != null) return _parse(cached.userMetadata);
      throw _handleException(e);
    }
  }

  Future<AddressBook> saveAddressBook(AddressBook book) async {
    try {
      debugPrint('[Address] saveAddressBook count=${book.addresses.length}');
      if (_client.auth.currentUser == null) {
        throw const AddressException('Sesi tidak ditemukan. Silakan login kembali.');
      }

      final response = await _client.auth.updateUser(
        UserAttributes(data: {
          _addressesKey: book.addresses.map((address) => address.toMap()).toList(),
          _selectedKey: book.selectedId,
        }),
      );

      return _parse(response.user?.userMetadata);
    } catch (e) {
      debugPrint('[Address] saveAddressBook error: $e');
      throw _handleException(e);
    }
  }

  AddressBook _parse(Map<String, dynamic>? metadata) {
    final rawList = metadata?[_addressesKey];
    final addresses = rawList is List
        ? rawList
            .whereType<Map>()
            .map((item) => CustomerAddress.fromMap(Map<String, dynamic>.from(item)))
            .where((address) => address.id.isNotEmpty)
            .toList()
        : <CustomerAddress>[];

    return AddressBook(
      addresses: addresses,
      selectedId: metadata?[_selectedKey] as String?,
    );
  }

  AddressException _handleException(Object error) {
    if (error is AddressException) return error;

    if (error is AuthException) {
      return AddressException(error.message);
    }

    if (error is SocketException ||
        error.toString().toLowerCase().contains('clientexception') ||
        error.toString().toLowerCase().contains('network')) {
      return const AddressException('Tidak ada koneksi internet. Periksa jaringan Anda.');
    }

    return AddressException('Terjadi kesalahan: $error');
  }
}
