import 'package:africaonlinestores/features/app_lock/domain/app_lock_models.dart';
import 'package:local_auth/local_auth.dart';

abstract interface class NativeAppLockService {
  Future<AppLockResult> checkBiometricAvailability();
  Future<AppLockResult> authenticateBiometric({required String reason});
  Future<void> cancel();
}

class LocalAuthAppLockService implements NativeAppLockService {
  LocalAuthAppLockService({LocalAuthentication? authentication})
    : _authentication = authentication ?? LocalAuthentication();

  final LocalAuthentication _authentication;

  @override
  Future<AppLockResult> checkBiometricAvailability() async {
    try {
      final bool supported = await _authentication.isDeviceSupported();
      if (!supported) {
        return const AppLockResult(AppLockError.unsupported);
      }

      final bool canCheck = await _authentication.canCheckBiometrics;
      if (!canCheck) {
        return const AppLockResult(AppLockError.hardwareUnavailable);
      }

      final List<BiometricType> enrolled = await _authentication
          .getAvailableBiometrics();
      return enrolled.isEmpty
          ? const AppLockResult(AppLockError.notEnrolled)
          : const AppLockResult.success();
    } on LocalAuthException catch (error) {
      return AppLockResult(_mapCode(error.code));
    } catch (_) {
      return const AppLockResult(AppLockError.unknown);
    }
  }

  @override
  Future<AppLockResult> authenticateBiometric({required String reason}) async {
    try {
      final bool authenticated = await _authentication.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      return authenticated
          ? const AppLockResult.success()
          : const AppLockResult(AppLockError.authenticationFailed);
    } on LocalAuthException catch (error) {
      return AppLockResult(_mapCode(error.code));
    } catch (_) {
      return const AppLockResult(AppLockError.unknown);
    }
  }

  @override
  Future<void> cancel() async {
    await _authentication.stopAuthentication();
  }

  AppLockError _mapCode(LocalAuthExceptionCode code) {
    switch (code) {
      case LocalAuthExceptionCode.authInProgress:
        return AppLockError.alreadyInProgress;
      case LocalAuthExceptionCode.uiUnavailable:
        return AppLockError.hardwareTemporarilyUnavailable;
      case LocalAuthExceptionCode.userCanceled:
        return AppLockError.userCancelled;
      case LocalAuthExceptionCode.timeout:
        return AppLockError.authenticationFailed;
      case LocalAuthExceptionCode.systemCanceled:
        return AppLockError.backgroundInterrupted;
      case LocalAuthExceptionCode.noCredentialsSet:
        return AppLockError.noDeviceCredential;
      case LocalAuthExceptionCode.noBiometricsEnrolled:
        return AppLockError.notEnrolled;
      case LocalAuthExceptionCode.noBiometricHardware:
        return AppLockError.hardwareUnavailable;
      case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
        return AppLockError.hardwareTemporarilyUnavailable;
      case LocalAuthExceptionCode.temporaryLockout:
        return AppLockError.temporaryLockout;
      case LocalAuthExceptionCode.biometricLockout:
        return AppLockError.permanentLockout;
      case LocalAuthExceptionCode.userRequestedFallback:
        return AppLockError.systemCancelled;
      case LocalAuthExceptionCode.deviceError:
      case LocalAuthExceptionCode.unknownError:
        return AppLockError.unknown;
    }
  }
}
