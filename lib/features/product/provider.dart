import 'package:flutter/material.dart';

import '/core/constants/const.dart';
import '/core/di/service_locator.dart';
import '/core/utils/api_client.dart';
import '/core/utils/logger.dart';

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
  static const productApi = ApiRoutes.product;

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
      appLogger.e('❌ Failed to fetch product "$name": $e');
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
      await apiClient.client.post(productApi, data: payload);

      await fetchProducts();
      return true;
    } catch (e, stack) {
      appLogger.e('❌ Failed to create product: $e\n$stack');
      return false;
    }
  }

  Future<void> deleteProduct(String name) async {
    try {
      final encodedName = Uri.encodeComponent(name);
      await apiClient.client.delete('$productApi/$encodedName');
      _products.removeWhere((p) => p.name == name);
      notifyListeners();
    } catch (e) {
      if (e.toString().contains("LinkExistsError")) {
        throw Exception(
          "This product is linked to stock records and cannot be deleted. You can disable it instead.",
        );
      } else {
        rethrow;
      }
    }
  }
}
