import 'package:shared_preferences/shared_preferences.dart';

class SearchRecentStorage {
  static const key = 'search_recent_v1';

  static Future<List<String>> load() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(key) ?? [];
  }

  static Future<void> save(String term, List<String> current) async {
    final sp = await SharedPreferences.getInstance();

    final next = <String>[term, ...current.where((e) => e != term)];
    final trimmed = next.take(10).toList();

    await sp.setStringList(key, trimmed);
  }

  static Future<void> remove(String term, List<String> current) async {
    final sp = await SharedPreferences.getInstance();
    final next = current.where((e) => e != term).toList();
    await sp.setStringList(key, next);
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(key);
  }
}
