import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Session + lightweight auth preferences.
///
/// - `sid` is stored in secure storage.
/// - small prefs (remember-me, remembered email) use SharedPreferences.
class SessionStorage {
  static const _kSid = 'aos_sid';
  static const _kRememberMe = 'aos_remember_me';
  static const _kEmail = 'aos_email';

  // Using a single instance is fine; secure storage is lightweight.
  const SessionStorage({FlutterSecureStorage? secureStorage})
    : _secure = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secure;

  Future<String?> getSid() async {
    final sid = await _secure.read(key: _kSid);
    return (sid == null || sid.isEmpty) ? null : sid;
  }

  Future<void> setSid(String sid) async {
    await _secure.write(key: _kSid, value: sid);
  }

  Future<void> clearSid() async {
    await _secure.delete(key: _kSid);
  }

  Future<bool> getRememberMe() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kRememberMe) ?? true;
  }

  Future<void> setRememberMe(bool remember) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kRememberMe, remember);
  }

  Future<String> getRememberedEmail() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kEmail) ?? '';
  }

  Future<void> setRememberedEmail(String email) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kEmail, email);
  }

  Future<void> clearRememberedEmail() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kEmail);
  }
}
