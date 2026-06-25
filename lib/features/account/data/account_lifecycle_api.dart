import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/api_endpoints.dart';
import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/dio_failure_mapper.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/either.dart';

final accountLifecycleApiProvider = Provider<AccountLifecycleApi>((ref) {
  return AccountLifecycleApi(ref.read(apiClientProvider));
});

class AccountLifecycleApi {
  final ApiClient _client;

  const AccountLifecycleApi(this._client);

  Future<Either<Failure, String>> deleteAccount({
    required String confirmation,
    String? reason,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.deleteAccount,
        data: {'confirmation': confirmation, 'reason': reason?.trim() ?? ''},
      );
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);
      return Either.right(
        unwrapped.rightOrNull?['message']?.toString() ?? 'Account deleted.',
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to delete account.'));
    }
  }

  Future<Either<Failure, String>> requestRestore({
    required String email,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.requestRestoreAccount,
        data: {'email': email.trim()},
      );
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);
      return Either.right(
        unwrapped.rightOrNull?['message']?.toString() ??
            'If a restorable account exists, a restore code has been sent.',
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to request account restore.'));
    }
  }

  Future<Either<Failure, String>> restoreAccount({
    required String email,
    required String otp,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.restoreAccount,
        data: {'email': email.trim(), 'otp': otp.trim()},
      );
      final unwrapped = unwrapFrappe(res);
      if (unwrapped.isLeft) return Either.left(unwrapped.leftOrNull!);
      return Either.right(
        unwrapped.rightOrNull?['message']?.toString() ??
            'Account restored. Please login.',
      );
    } on DioException catch (e) {
      return Either.left(mapDioException(e));
    } catch (_) {
      return Either.left(const Failure('Failed to restore account.'));
    }
  }
}
