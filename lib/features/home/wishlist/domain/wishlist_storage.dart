import 'package:shared_preferences/shared_preferences.dart';

class WishlistStorage {
  static const _kKey = 'aos_wishlist_ids';

  Future<Set<String>> readIds() async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_kKey) ?? const <String>[];
    return list.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
  }

  Future<void> writeIds(Set<String> ids) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(_kKey, ids.toList());
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kKey);
  }
}
