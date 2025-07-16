import 'package:flutter/material.dart';

import '/core/constants/const.dart';
import '/core/di/service_locator.dart';
import '/core/utils/api_client.dart';

import '/features/product/domain/product.dart';
import '/features/product/domain/usecase.dart';

import 'data/remote.dart';

class ProductProvider with ChangeNotifier {
  final GetProductsUseCase getProductsUseCase;
  final CreateProductUseCase createProductUseCase;
  final UpdateProductUseCase updateProductUseCase;

  ProductProvider(
    this.getProductsUseCase,
    this.createProductUseCase,
    this.updateProductUseCase,
  );

  final apiClient = sl<APIClient>();

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

  Future<Product?> getProductByName(String name) async {
    try {
      final remoteDataSource = ProductRemoteDataSourceImpl(apiClient);
      final model = await remoteDataSource.getProductByName(name);
      return model.toEntity();
    } catch (e) {
      debugPrint('❌ Failed to fetch product "$name": $e');
      return null;
    }
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
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> createProductFromRaw(Map<String, dynamic> payload) async {
    try {
      debugPrint('📤 Creating product with payload: $payload');
      final response = await apiClient.client.post(
        PRODUCT_ENDPOINT,
        data: payload,
      );

      debugPrint('✅ Product created from provider: ${response.data}');
      await fetchProducts();
      return true;
    } catch (e, stack) {
      debugPrint('❌ Failed to create product: $e\n$stack');
      return false;
    }
  }

  Future<void> deleteProduct(String name) async {
    try {
      await apiClient.client.delete('$PRODUCT_ENDPOINT/$name');
      _products.removeWhere((p) => p.name == name);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
