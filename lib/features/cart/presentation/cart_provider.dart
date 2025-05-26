import 'package:flutter/foundation.dart';

import '../domain/cart_item.dart';
import '../domain/usecases/add_to_cart.dart';
import '../domain/usecases/clear_cart.dart';
import '../domain/usecases/get_cart.dart';
import '../domain/usecases/remove_from_cart.dart';
import '../domain/usecases/update_cart_quantity.dart';

class CartProvider extends ChangeNotifier {
  final GetCart getCart;
  final AddToCart addToCart;
  final RemoveFromCart removeFromCart;
  final UpdateCartQuantity updateCartQuantity;
  final ClearCart clearCart;

  CartProvider({
    required this.getCart,
    required this.addToCart,
    required this.removeFromCart,
    required this.updateCartQuantity,
    required this.clearCart,
  });

  List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  set _loading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadCart() async {
    _loading = true;
    try {
      _items = await getCart();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cart: $e');
      }
      _items = [];
    }
    _loading = false;
  }

  Future<void> add(CartItem item) async {
    try {
      final index = _items.indexWhere((e) => e.id == item.id);
      if (index != -1) {
        // Use updateQuantity internally for consistency
        await updateQuantity(item.id, _items[index].quantity + 1);
      } else {
        final newItem = item.copyWith(quantity: 1);
        _items.add(newItem);
        notifyListeners();
        await addToCart(newItem);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding item: $e');
      }
    }
  }

  Future<void> remove(String id) async {
    try {
      final index = _items.indexWhere((e) => e.id == id);
      if (index != -1) {
        _items.removeAt(index);
        notifyListeners();
        await removeFromCart(id);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing item: $e');
      }
    }
  }

  Future<void> updateQuantity(String id, int quantity) async {
    if (quantity < 1) {
      await remove(id);
      return;
    }
    try {
      final index = _items.indexWhere((e) => e.id == id);
      if (index != -1) {
        _items[index] = _items[index].copyWith(quantity: quantity);
        notifyListeners();
        await updateCartQuantity(id, quantity);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating quantity: $e');
      }
    }
  }

  Future<void> clear() async {
    try {
      _items.clear();
      notifyListeners();
      await clearCart();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cart: $e');
      }
    }
  }
}
