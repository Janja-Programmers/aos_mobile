import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:dio/dio.dart';

class CategoriesApi {
  CategoriesApi(this._client);
  final ApiClient _client;

  Future<Either<Failure, Map<String, dynamic>>> getCategories({
    bool includeInactive = false,
  }) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        ApiEndpoints.getCategoriesEndpoint,
        queryParameters: {if (includeInactive) 'include_inactive': 1},
      );
      return unwrapFrappe(res);
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Unexpected error. Please try again.'));
    }
  }
}
