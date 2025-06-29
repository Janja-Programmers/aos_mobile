import 'package:flutter/material.dart';

import '/core/utils/logger.dart';

import 'domain/product.dart';
import 'domain/usecase.dart';

class ProductProvider with ChangeNotifier {
  final GetProductsUseCase getProductsUseCase;
  final CreateProductUseCase createProductUseCase;
  final GetVendorProductsUseCase getVendorProductsUseCase;

  ProductProvider(
    this.getProductsUseCase,
    this.createProductUseCase,
    this.getVendorProductsUseCase,
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

  Future<void> createProduct(Product product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await createProductUseCase(product);

    result.fold((failure) => _error = failure.message, (createdProduct) {
      _products.add(createdProduct);
      appLogger.i('Product created: ${createdProduct.itemName}');
    });

    _isLoading = false;
    notifyListeners();
  }
}
