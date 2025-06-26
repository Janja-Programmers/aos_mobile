import 'package:flutter/material.dart';

import 'domain/product.dart';
import 'domain/usecase.dart';

class ProductProvider with ChangeNotifier {
  final GetProductsUseCase getProductsUseCase;

  ProductProvider(this.getProductsUseCase);

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
}
