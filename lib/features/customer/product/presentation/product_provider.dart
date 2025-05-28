import 'package:amani_mall/features/shared/item/domain/usecases/get_item_by_name.dart';
import 'package:amani_mall/features/shared/item/domain/usecases/get_items.dart';
import 'package:flutter/material.dart';
import '../../../shared/item/domain/product.dart';

class ProductProvider extends ChangeNotifier {
  final GetItems getProducts;
  final GetItemByName getProductDetails;

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
      _products = (await getProducts()).cast<Product>();
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
      _selectedProduct = (await getProductDetails(id)) as Product?;
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
