import 'package:flutter/material.dart';
import '../../../shared/products/domain/product.dart';
import '../../../shared/products/domain/usecases/get_products.dart';
import '../../../shared/products/domain/usecases/get_product_details.dart';

class ProductProvider extends ChangeNotifier {
  final GetProducts getProducts;
  final GetProductDetails getProductDetails;

  ProductProvider({required this.getProducts, required this.getProductDetails});

  List<Product> _products = [];
  List<Product> get products => _products;

  Product? _selectedProduct;
  Product? get selectedProduct => _selectedProduct;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await getProducts();
    } catch (e) {
      _error = 'Failed to load products';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProductDetails(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedProduct = await getProductDetails(id);
    } catch (e) {
      _error = 'Failed to load product details';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearSelectedProduct() {
    _selectedProduct = null;
  }
}
