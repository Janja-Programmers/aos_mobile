import 'dart:convert';

import '/core/constants/const.dart';
import '/core/utils/api_client.dart';
import '/core/utils/logger.dart';

import 'model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<List<ProductModel>> vendorProducts(String vendor);
  Future<ProductModel> createProduct(ProductModel model);
  Future<ProductModel> updateProduct(ProductModel model);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final APIClient client;

  ProductRemoteDataSourceImpl(this.client);

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await client.client.get(ALL_PRODUCTS_ENDPOINT);
    final List data = response.data['message'];
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> vendorProducts(String vendor) async {
    final response = await client.client.get(
      ALL_PRODUCTS_ENDPOINT,
      queryParameters: {
        'filters': jsonEncode([
          ['Product', 'owner', '=', vendor],
        ]),
      },
    );

    final List data = response.data['message'];
    appLogger.i('Fetched vendor products: ${data.map((e) => e.toString())}');
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<ProductModel> createProduct(ProductModel model) async {
    final response = await client.client.post(
      CREATE_PRODUCT_ENDPOINT,
      data: model.toJson(),
    );

    final data = response.data['data'];

    if (data == null || data is! Map<String, dynamic>) {
      throw Exception('Failed to parse created product');
    }
    return ProductModel.fromJson(data);
  }

  @override
  Future<ProductModel> updateProduct(ProductModel model) async {
    final response = await client.client.put(
      '$CREATE_PRODUCT_ENDPOINT/${model.name}',
      data: model.toJson(),
    );

    final data = response.data['data'];

    if (data == null || data is! Map<String, dynamic>) {
      throw Exception('Failed to parse updated product');
    }

    return ProductModel.fromJson(data);
  }
}
