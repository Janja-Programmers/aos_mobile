import '/core/constants/const.dart';
import '/core/utils/api_client.dart';
import '/core/utils/logger.dart';

import 'model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> createProduct(ProductModel model);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final APIClient client;

  ProductRemoteDataSourceImpl(this.client);

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await client.client.get(ALL_PRODUCTS_ENDPOINT);
    final List data = response.data['message'];
    appLogger.i('Fetched products: ${data.map((e) => e.toString())} items');
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<ProductModel> createProduct(ProductModel model) async {
    final response = await client.client.post(
      CREATE_PRODUCTS_ENDPOINT,
      data: model.toJson(),
    );
    final data = response.data['message'];
    appLogger.i('Created product: $data');
    return ProductModel.fromJson(data);
  }
}
