import 'package:dio/dio.dart';

import '/core/constants/const.dart';
import '/core/errors/exception.dart';
import '/core/utils/api_client.dart';

import 'model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> createProduct(ProductModel model);
  Future<ProductModel> updateProduct(ProductModel model);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final APIClient client;
  static const productApi = ApiRoutes.product;

  ProductRemoteDataSourceImpl(this.client);

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await client.client.get(
        productApi,
        queryParameters: {
          'fields': '["name","item_name","category", "modified", "creation"]',
        },
      );

      final List data = response.data['data'];

      data.sort((a, b) {
        final aDate = DateTime.parse(a['modified'] ?? a['creation']);
        final bDate = DateTime.parse(b['modified'] ?? b['creation']);
        return bDate.compareTo(aDate);
      });

      return data.map((json) => ProductModel.fromJson(json)).toList();
    } on DioException catch (e) {
      handleException(e);
      rethrow;
    }
  }

  Future<ProductModel> getProductByName(String name) async {
    final endpoint = '$productApi/$name';

    try {
      final response = await client.client.get(endpoint);

      final data = response.data['data'];

      return ProductModel.fromJson(data);
    } on DioException catch (e) {
      handleException(e);
      rethrow;
    }
  }

  @override
  Future<ProductModel> createProduct(ProductModel model) async {
    try {
      final dataMap = model.toJson();

      // Inject Frappe-required structure into website_specifications
      dataMap['website_specifications'] =
          model.websiteSpecifications
              ?.map(
                (spec) => {
                  'doctype': 'Product Website Specification',
                  'label': spec.label,
                  'description': spec.description,
                  'parenttype': 'Product',
                  'parentfield': 'website_specifications',
                },
              )
              .toList();

      final formData = FormData.fromMap({
        ...dataMap,
        if (model.imageFile != null)
          'image': await MultipartFile.fromFile(
            model.imageFile!.path,
            filename: model.imageFile!.path.split('/').last,
          ),
        if (model.videoFile != null)
          'demo_video': await MultipartFile.fromFile(
            model.videoFile!.path,
            filename: model.videoFile!.path.split('/').last,
          ),
      });

      final response = await client.client.post(
        productApi,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      final data = response.data['data'];

      if (data == null || data is! Map<String, dynamic>) {
        throw Exception('Failed to parse created product');
      }

      return ProductModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  @override
  Future<ProductModel> updateProduct(ProductModel model) async {
    try {
      final dataMap = model.toJson();

      // Inject Frappe-required structure into website_specifications
      dataMap['website_specifications'] =
          model.websiteSpecifications
              ?.map(
                (spec) => {
                  'doctype': 'Product Website Specification',
                  if (spec.name != null) 'name': spec.name,
                  'label': spec.label,
                  'description': spec.description,
                  'parent': model.name,
                  'parenttype': 'Product',
                  'parentfield': 'website_specifications',
                },
              )
              .toList();

      final formData = FormData.fromMap({
        ...dataMap,
        if (model.imageFile != null)
          'image': await MultipartFile.fromFile(
            model.imageFile!.path,
            filename: model.imageFile!.path.split('/').last,
          ),
        if (model.videoFile != null)
          'demo_video': await MultipartFile.fromFile(
            model.videoFile!.path,
            filename: model.videoFile!.path.split('/').last,
          ),
      });

      final response = await client.client.put(
        '$productApi/${model.name}',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      final data = response.data['data'];

      if (data == null || data is! Map<String, dynamic>) {
        throw Exception('Failed to parse updated product');
      }

      return ProductModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }
}
