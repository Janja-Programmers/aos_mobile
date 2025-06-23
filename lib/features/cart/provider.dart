import 'package:flutter/material.dart';

import 'domain/cart.dart';
import 'domain/usecase.dart';

class CartProvider with ChangeNotifier {
  final GetCartItemsUseCase getCartItems;
  final AddToCartUseCase addToCart;
  final RemoveFromCartUseCase removeFromCart;
  final ClearCartUseCase clearCart;
  final UpdateCartItemQuantityUseCase updateQty;

  CartProvider({
    required this.getCartItems,
    required this.addToCart,
    required this.removeFromCart,
    required this.clearCart,
    required this.updateQty,
  });

  List<CartItem> _items = [];
  List<CartItem> get items => _items;

  double get grandTotal =>
      _items.fold(0, (total, item) => total + item.price * item.quantity);

  Future<void> loadCart() async {
    _items = await getCartItems();
    notifyListeners();
  }

  Future<void> add(CartItem item) async {
    await addToCart(item);
    await loadCart();
  }

  Future<void> remove(String code) async {
    await removeFromCart(code);
    await loadCart();
  }

  Future<void> clear() async {
    await clearCart();
    await loadCart();
  }

  Future<void> updateQuantity(String code, int qty) async {
    await updateQty(code, qty);
    await loadCart();
  }
}
