import 'dart:convert';

import 'package:africaonlinestores/features/app_lock/domain/app_lock_models.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class AppLockPreferenceRepository {
  Future<AppLockPreference> read(String accountId);
  Future<void> write(String accountId, AppLockPreference preference);
  Future<void> clear(String accountId);
}

class SecureAppLockPreferenceRepository implements AppLockPreferenceRepository {
  const SecureAppLockPreferenceRepository({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  String _key(String accountId) {
    final String encoded = base64Url.encode(
      utf8.encode(accountId.trim().toLowerCase()),
    );
    return 'aos_app_lock_$encoded';
  }

  @override
  Future<AppLockPreference> read(String accountId) async {
    final String? raw = await _storage.read(key: _key(accountId));
    if (raw == null || raw.isEmpty) return AppLockPreference.disabled;

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return AppLockPreference.disabled;

      // Version 1 used OS authentication only. Preserve an enabled legacy
      // preference by migrating it to the biometric method.
      if (decoded['method'] == null && decoded['enabled'] == true) {
        final AppLockPreference migrated = AppLockPreference(
          method: AppLockMethod.biometric,
          timeout: AppLockTimeout.fromStorage(decoded['timeout']?.toString()),
        );
        await write(accountId, migrated);
        return migrated;
      }

      final AppLockMethod? method = _methodFromStorage(
        decoded['method']?.toString(),
      );
      if (method == null) return AppLockPreference.disabled;

      final AppLockPreference preference = AppLockPreference(
        method: method,
        timeout: AppLockTimeout.fromStorage(decoded['timeout']?.toString()),
        secretHash: decoded['secret_hash']?.toString(),
        salt: decoded['salt']?.toString(),
        hashIterations:
            int.tryParse(decoded['hash_iterations']?.toString() ?? '') ??
            120000,
        version: int.tryParse(decoded['version']?.toString() ?? '') ?? 2,
      );
      return preference.hasUsableSecret
          ? preference
          : AppLockPreference.disabled;
    } on FormatException {
      return AppLockPreference.disabled;
    }
  }

  @override
  Future<void> write(String accountId, AppLockPreference preference) async {
    if (!preference.enabled) {
      await clear(accountId);
      return;
    }

    await _storage.write(
      key: _key(accountId),
      value: jsonEncode(<String, Object?>{
        'version': preference.version,
        'method': preference.method!.name,
        'timeout': preference.timeout.storageValue,
        'secret_hash': preference.secretHash,
        'salt': preference.salt,
        'hash_iterations': preference.hashIterations,
      }),
    );
  }

  @override
  Future<void> clear(String accountId) => _storage.delete(key: _key(accountId));

  AppLockMethod? _methodFromStorage(String? value) {
    for (final AppLockMethod method in AppLockMethod.values) {
      if (method.name == value) return method;
    }
    return null;
  }
}
