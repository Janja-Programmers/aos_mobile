import 'cart.dart';

abstract class CartRepo {
  Future<void> addItem(CartItem item);
  Future<List<CartItem>> getItems();
  Future<void> removeItem(String code);
  Future<void> clearCart();
  Future<void> updateQuantity(String code, int quantity);
}
