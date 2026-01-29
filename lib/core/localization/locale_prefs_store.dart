import 'package:shared_preferences/shared_preferences.dart';

import 'package:africaonlinestores/core/localization/locale_prefs.dart';

/// Local persistence for [LocalePrefs].
class LocalePrefsStore {
  static const _kKey = 'aos_locale_prefs';

  Future<LocalePrefs?> read() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getString(_kKey);
    if (v == null || v.isEmpty) return null;
    try {
      return LocalePrefs.fromJson(v);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(LocalePrefs prefs) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kKey, prefs.toJson());
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kKey);
  }
}
