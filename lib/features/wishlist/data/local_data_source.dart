import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'model.dart';

abstract class WishlistLocalDataSource {
  Future<List<WishlistItemModel>> getWishlistItems();
  Future<void> saveWishlistItems(List<WishlistItemModel> items);
}

class WishlistLocalDataSourceImpl implements WishlistLocalDataSource {
  static const String _wishlistKey = 'wishlist_items';

  @override
  Future<List<WishlistItemModel>> getWishlistItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_wishlistKey);

    if (jsonString != null) {
      final decoded = json.decode(jsonString) as List;

      final items =
          decoded
              .map((item) => WishlistItemModel.fromJson(item))
              .where((item) => item.id.isNotEmpty)
              .toList();

      await saveWishlistItems(items);

      return items;
    } else {
      return [];
    }
  }

  @override
  Future<void> saveWishlistItems(List<WishlistItemModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_wishlistKey, encoded);
  }
}
