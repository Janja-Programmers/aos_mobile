import 'package:flutter/material.dart';

import 'domain/address.dart';
import 'domain/repo.dart';

enum AddressStatus { idle, loading, success, error }

class AddressProvider with ChangeNotifier {
  final AddressRepository repository;

  AddressProvider({required this.repository});

  Address? _selectedAddress;
  Address? get selectedAddress => _selectedAddress;

  List<Address> _addresses = [];
  List<Address> get addresses => _addresses;

  AddressStatus _status = AddressStatus.idle;
  AddressStatus get status => _status;

  String? _error;
  String? get error => _error;

  String? _message;
  String? get message => _message;

  final bool _loading = false;
  bool get isLoading => _loading;

  // Set the selected address
  void setSelectedAddress(Address address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void clearStatus() {
    _status = AddressStatus.idle;
    _error = null;
    _message = null;
    notifyListeners();
  }

  Future<String?> createShippingAddress(Address address) async {
    _setLoading();

    final result = await repository.createShippingAddress(address);

    return result.fold(
      (failure) {
        _setError(failure.message);
        return null;
      },
      (name) {
        _setSuccess('Address created successfully');
        return name;
      },
    );
  }

  Future<String?> updateShippingAddress(Address address) async {
    _setLoading();

    final result = await repository.updateShippingAddress(address);

    final updated = result.fold(
      (failure) {
        _setError(failure.message);
        return null;
      },
      (_) {
        _setSuccess('Address updated');
        return address.name;
      },
    );

    // Refresh from remote
    await fetchShippingAddresses();

    return updated;
  }

  Future<void> fetchShippingAddresses() async {
    _setLoading();

    final result = await repository.fetchShippingAddresses();

    result.fold((failure) => _setError(failure.message), (data) {
      _addresses = data;
      _setSuccess(null); // silently return to idle if no message
    });
  }

  // Internal state helpers
  void _setLoading() {
    _status = AddressStatus.loading;
    _error = null;
    _message = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _status = AddressStatus.error;
    _error = msg;
    _message = msg;
    notifyListeners();
  }

  void _setSuccess(String? msg) {
    _status = AddressStatus.success;
    _error = null;
    _message = msg;
    notifyListeners();
  }
}
