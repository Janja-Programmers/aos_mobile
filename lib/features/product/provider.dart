import 'package:flutter/material.dart';

import '/core/utils/logger.dart';
import '/features/product/domain/product.dart';
import '/features/product/domain/usecase.dart';

class ProductProvider with ChangeNotifier {
  final GetProductsUseCase getProductsUseCase;
  final CreateProductUseCase createProductUseCase;
  final GetVendorProductsUseCase getVendorProductsUseCase;
  final UpdateProductUseCase updateProductUseCase;

  ProductProvider(
    this.getProductsUseCase,
    this.createProductUseCase,
    this.getVendorProductsUseCase,
    this.updateProductUseCase,
  );

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getProductsUseCase();

    result.fold(
      (failure) => _error = failure.message,
      (data) => _products = data,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchVendorProducts(String vendor) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getVendorProductsUseCase(vendor);

    result.fold(
      (failure) => _error = failure.message,
      (data) => _products = data,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createProduct(Product product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await createProductUseCase(product);

    _isLoading = false;

    return result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
        return false;
      },
      (createdProduct) {
        _products.add(createdProduct);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> updateExistingItem(Product product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await updateProductUseCase(product);

    _isLoading = false;
    notifyListeners();

    return result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
        return false;
      },
      (updated) {
        final index = _products.indexWhere((p) => p.name == updated.name);
        if (index != -1) {
          _products[index] = updated;
        }
        appLogger.i('Product updated: ${updated.itemName}');
        notifyListeners();
        return true;
      },
    );
  }
}
