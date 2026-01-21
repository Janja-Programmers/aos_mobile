import 'package:shared_preferences/shared_preferences.dart';

/// Simple key-value storage for session + lightweight auth prefs.
class SessionStorage {
  static const _kSid = 'aos_sid';
  static const _kRememberMe = 'aos_remember_me';
  static const _kEmail = 'aos_email';

  Future<String?> getSid() async {
    final sp = await SharedPreferences.getInstance();
    final sid = sp.getString(_kSid);
    return (sid == null || sid.isEmpty) ? null : sid;
  }

  Future<void> setSid(String sid) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kSid, sid);
  }

  Future<void> clearSid() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kSid);
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
