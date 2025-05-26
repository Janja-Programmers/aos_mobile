import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<void> saveCartItems(List<CartItemModel> items);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  static const String _cartKey = 'cart_items';

  @override
  Future<List<CartItemModel>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cartKey);

    if (jsonString != null) {
      final decoded = json.decode(jsonString);
      if (decoded is List) {
        return decoded
            .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return decoded.map((item) => CartItemModel.fromJson(item)).toList();
    } else {
      return [];
    }
  }

  @override
  Future<void> saveCartItems(List<CartItemModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_cartKey, encoded);
  }
}
