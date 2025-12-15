import 'package:dio/dio.dart';

import '/core/constants/const.dart';
import '/core/utils/api_client.dart';

import 'product_model.dart';

class ProductRemote {
  final APIClient client;
  static const productApi = ApiRoutes.product;

  ProductRemote(this.client);

  Future<List<ProductModel>> getProducts() async {
    final response = await client.client.get(
      productApi,
      queryParameters: {
        'fields':
            '["name","item_name","category","modified","creation","is_stock_item"]',
      },
    );

    final List data = response.data['data'];
    data.sort((a, b) {
      final aDate = DateTime.parse(a['modified'] ?? a['creation']);
      final bDate = DateTime.parse(b['modified'] ?? b['creation']);
      return bDate.compareTo(aDate);
    });

    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<ProductModel> getProductByName(String name) async {
    final response = await client.client.get('$productApi/$name');
    final data = response.data['data'];
    return ProductModel.fromJson(data);
  }

  Future<ProductModel> createProduct(ProductModel model) async {
    final formData = FormData.fromMap({
      ...model.toMapForApi(),
      if (model.image != null)
        'image': await MultipartFile.fromFile(
          model.image!,
          filename: model.image!.split('/').last,
        ),
      if (model.demoVideo != null)
        'demo_video': await MultipartFile.fromFile(
          model.demoVideo!,
          filename: model.demoVideo!.split('/').last,
        ),
    });

    final response = await client.client.post(
      productApi,
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );
    return ProductModel.fromJson(response.data['data']);
  }

  Future<ProductModel> updateProduct(ProductModel model) async {
    final formData = FormData.fromMap({
      ...model.toMapForApi(),
      if (model.image != null)
        'image': await MultipartFile.fromFile(
          model.image!,
          filename: model.image!.split('/').last,
        ),
      if (model.demoVideo != null)
        'demo_video': await MultipartFile.fromFile(
          model.demoVideo!,
          filename: model.demoVideo!.split('/').last,
        ),
    });

    final response = await client.client.put(
      '$productApi/${model.name}',
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );
    return ProductModel.fromJson(response.data['data']);
  }

  Future<void> deleteProduct(String name) async {
    final encodedName = Uri.encodeComponent(name);
    await client.client.delete('$productApi/$encodedName');
  }
}
