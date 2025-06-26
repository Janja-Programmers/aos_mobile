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
  Future<bool> createShippingAddress(Address address) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      await repository.createShippingAddress(address);
      await fetchShippingAddresses(); // refresh local cache
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get all saved shipping addresses (local)
  Future<void> fetchShippingAddresses() async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      _addresses = await repository.fetchShippingAddresses();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
