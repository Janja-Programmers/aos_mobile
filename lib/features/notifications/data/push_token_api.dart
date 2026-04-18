import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/failure.dart';

import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/notifications/domain/push_token_device.dart';

class PushTokenApi {
  final ApiClient _apiClient;

  const PushTokenApi(this._apiClient);

  // =====================================================
  // REGISTER PUSH TOKEN
  // =====================================================
  Future<Either<Failure, bool>> registerPushToken({
    required PushTokenDevice device,
  }) async {
    try {
      appLogger.i('registerPushToken API LAYER JSON: ${device.toJson()}');
      final res = await _apiClient.post(
        ApiEndpoints.registerPushToken,
        data: device.toJson(),
      );

      final result = unwrapFrappe(res);

      if (result.isLeft) {
        return Either.left(result.leftOrNull!);
      }

      appLogger.i('Push token registered');

      return Either.right(true);
    } on DioException catch (e, s) {
      appLogger.e('registerPushToken Dio error', error: e, stackTrace: s);
      return Either.left(mapDioException(e));
    } catch (e, s) {
      appLogger.e('registerPushToken unknown error', error: e, stackTrace: s);
      return Either.left(const Failure('Failed to register push token'));
    }
  }

  // =====================================================
  // DEACTIVATE PUSH TOKEN
  // =====================================================
  Future<Either<Failure, bool>> deactivatePushToken({
    required String token,
  }) async {
    try {
      final res = await _apiClient.post(
        ApiEndpoints.deactivatePushToken,
        data: {'token': token},
      );

      final result = unwrapFrappe(res);

      if (result.isLeft) {
        return Either.left(result.leftOrNull!);
      }

      appLogger.i('Push token deactivated');

      return Either.right(true);
    } on DioException catch (e, s) {
      appLogger.e('deactivatePushToken Dio error', error: e, stackTrace: s);
      return Either.left(mapDioException(e));
    } catch (e, s) {
      appLogger.e('deactivatePushToken unknown error', error: e, stackTrace: s);
      return Either.left(const Failure('Failed to deactivate push token'));
    }
  }
}
