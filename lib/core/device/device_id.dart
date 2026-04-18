import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceId {
  static const _key = 'device_id';

  static Future<String> get() async {
    final prefs = await SharedPreferences.getInstance();

    String? id = prefs.getString(_key);

    if (id != null && id.isNotEmpty) {
      return id;
    }

    // 🔥 Generate new
    id = const Uuid().v4();

    await prefs.setString(_key, id);

    return id;
  }
}
