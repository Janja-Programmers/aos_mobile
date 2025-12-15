import 'package:flutter/material.dart';

import 'data/product_model.dart';
import 'data/product_repository.dart';

class ProductProvider with ChangeNotifier {
  final ProductRepository repository;

  ProductProvider(this.repository);

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _products = await repository.getProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProduct(ProductModel model) async {
    _isLoading = true;
    notifyListeners();
    try {
      final created = await repository.createProduct(model);
      _products.add(created);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ProductModel?> getProductByName(String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final product = await repository.getProductByName(name);
      return product;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateExistingItem(ProductModel model) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updated = await repository.updateProduct(model);
      final index = _products.indexWhere((p) => p.name == updated.name);
      if (index != -1) _products[index] = updated;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      await repository.deleteProduct(name);

      _products.removeWhere((p) => p.name == name);
      return true;
    } catch (e) {
      if (e.toString().contains('LinkExistsError')) {
        _error =
            'This product is linked to stock records and cannot be deleted. '
            'You can disable it instead.';
      } else {
        _error = e.toString();
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
