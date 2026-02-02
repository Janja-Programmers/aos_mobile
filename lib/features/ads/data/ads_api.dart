import 'dart:io';

import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';

class AdsApi {
  AdsApi(this._client);
  final ApiClient _client;

  Dio get _dio => _client.dio;

  Future<Either<Failure, List<Map<String, dynamic>>>> getLocations({
    required String countryCode,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.getLocationsEndpoint,
        queryParameters: {'country': countryCode},
      );
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);
      final p = unwrapped.rightOrNull!;
      final data = (p['data'] is Map)
          ? Map<String, dynamic>.from(p['data'] as Map)
          : <String, dynamic>{};
      final list =
          data['locations'] ?? data['items'] ?? data['data'] ?? data['list'];
      if (list is List) {
        return Either.right(
          list
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
        );
      }
      // Sometimes backend returns {data:[...]}
      if (p['data'] is List) {
        return Either.right(
          (p['data'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
        );
      }
      return Either.right(const <Map<String, dynamic>>[]);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to load locations.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getCategorySchema({
    required String categoryId,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.getCategorySchemaEndpoint,
        queryParameters: {'category': categoryId},
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to load category schema.'));
    }
  }

  Future<Either<Failure, String>> uploadMedia({required File file}) async {
    try {
      final filename = file.path.split(Platform.pathSeparator).last;
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: filename),
        'is_private': '0',
      });

      final res = await _dio.post(ApiEndpoints.uploadFileEndpoint, data: form);

      final body = res.data;
      if (body is Map && body['message'] is Map) {
        final msg = Map<String, dynamic>.from(body['message'] as Map);
        final url = (msg['file_url'] ?? '').toString();
        if (url.isNotEmpty) return Either.right(url);
      }
      return Either.left(const Failure('Failed to upload file.'));
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to upload file.'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> createAd({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final res = await _dio.post(ApiEndpoints.createAdEndpoint, data: payload);
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to create ad.'));
    }
  }
}
