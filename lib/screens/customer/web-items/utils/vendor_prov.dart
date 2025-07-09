import 'package:flutter/material.dart';
import 'vendor_utils.dart';

class VendorProvider extends ChangeNotifier {
  final VendorUtils utils;

  VendorProvider({required this.utils});

  VendorDetails? _vendor;
  bool _loading = false;

  VendorDetails? get vendor => _vendor;
  bool get loading => _loading;

  Future<void> loadVendor(String vendorName) async {
    _loading = true;
    notifyListeners();

    _vendor = await utils.fetchVendor(vendorName);

    _loading = false;
    notifyListeners();
  }
}
