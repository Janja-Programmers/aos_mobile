import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/notifications/data/notification_repository_impl.dart';
import 'package:africaonlinestores/features/notifications/domain/push_token_device.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class PushTokenController extends StateNotifier<AsyncValue<void>> {
  final PushTokenRepository _repository;

  PushTokenController(this._repository) : super(const AsyncData(null));

  Future<Either<Failure, bool>> registerPushToken(
    PushTokenDevice device,
  ) async {
    appLogger.i(
      'PushTokenController -> registerPushToken: ${device.deviceType.value}',
    );

    state = const AsyncLoading();

    final result = await _repository.registerPushToken(device);

    if (result.isLeft) {
      final failure = result.leftOrNull!;
      appLogger.e(
        'PushTokenController -> registerPushToken failed',
        error: failure.message,
      );
      state = AsyncError(failure, StackTrace.current);
      return Either.left(failure);
    }

    appLogger.i('PushTokenController -> registerPushToken success');
    state = const AsyncData(null);
    return Either.right(true);
  }

  Future<Either<Failure, bool>> deactivatePushToken(String token) async {
    appLogger.i('PushTokenController -> deactivatePushToken');

    state = const AsyncLoading();

    final result = await _repository.deactivatePushToken(token);

    if (result.isLeft) {
      final failure = result.leftOrNull!;
      appLogger.e(
        'PushTokenController -> deactivatePushToken failed',
        error: failure.message,
      );
      state = AsyncError(failure, StackTrace.current);
      return Either.left(failure);
    }

    appLogger.i('PushTokenController -> deactivatePushToken success');
    state = const AsyncData(null);
    return Either.right(true);
  }

  void reset() {
    appLogger.i('PushTokenController -> reset');
    state = const AsyncData(null);
  }
}
