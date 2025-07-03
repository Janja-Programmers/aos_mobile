import 'dart:convert';

import 'package:dio/dio.dart';

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
    try {
      final dataMap = model.toJson();

      // 🔁 Encode website_specifications as JSON string
      if (model.websiteSpecifications != null) {
        dataMap['website_specifications'] =
            model.websiteSpecifications
                ?.map(
                  (e) => {
                    'doctype': 'Product Website Specification',
                    'label': e.label,
                    'description': e.description,
                  },
                )
                .toList();
      }

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

      for (var field in formData.fields) {
        appLogger.i('📝 Field: ${field.key}: ${field.value}');
      }

      final response = await client.client.post(
        CREATE_PRODUCT_ENDPOINT,
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
        '$CREATE_PRODUCT_ENDPOINT/${model.name}',
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



// options: Options(
//   headers: {
//     'Authorization': 'Bearer your_token_here', // Replace with your token
//   },
// ),
      
