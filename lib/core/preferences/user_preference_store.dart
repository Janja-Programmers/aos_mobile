import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:africaonlinestores/core/preferences/user_preference_state.dart';

class UserPreferenceStore {
  static const _key = "aos_user_preferences";

  Future<void> save(UserPreferenceState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, state.toJson().toString());
  }

  Future<UserPreferenceState?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    final map = Map<String, dynamic>.from(
      raw.contains("{") ? jsonDecode(raw) : {},
    );
    return UserPreferenceState.fromJson(map);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
