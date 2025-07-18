import 'package:flutter/material.dart';

import 'domain/address.dart';
import 'domain/repo.dart';

class AddressProvider with ChangeNotifier {
  final AddressRepository repository;

  AddressProvider({required this.repository});

  List<Address> _addresses = [];
  List<Address> get addresses => _addresses;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Create and persist address (remote + local)
  Future<String?> createShippingAddress(Address address) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    final result = await repository.createShippingAddress(address);

    _isLoading = false;
    notifyListeners();

    return result.fold((failure) {
      _error = failure.message;
      return null;
    }, (name) => name);
  }

  /// Get all saved shipping addresses (local)
  Future<void> fetchShippingAddresses() async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    final result = await repository.fetchShippingAddresses();

    _isLoading = false;
    result.fold(
      (failure) => _error = failure.message,
      (data) => _addresses = data,
    );

    notifyListeners();
  }
}
