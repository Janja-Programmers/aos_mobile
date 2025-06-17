import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'wishlist_item_model.dart';

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
      return decoded.map((item) => WishlistItemModel.fromJson(item)).toList();
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
