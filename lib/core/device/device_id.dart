import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeviceId {
  DeviceId._();

  static const _key = 'aos_device_id';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static Future<String> get() async {
    final existing = await _storage.read(key: _key);

    if (existing != null && existing.trim().isNotEmpty) {
      return existing;
    }

    final id = const Uuid().v4();
    await _storage.write(key: _key, value: id);

    return id;
  }
}
