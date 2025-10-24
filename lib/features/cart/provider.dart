import 'package:flutter/material.dart';

import '/core/di/service_locator.dart';
import '/core/utils/api_client.dart';

import '/screens/auth/auth_provider.dart';

import '../order/domain/sales_order.dart';
import '../order/domain/usecases.dart';

import 'domain/repo.dart';
import 'domain/cart.dart';
import 'domain/usecase.dart';

class CartProvider with ChangeNotifier {
  final GetCartItemsUseCase getCartItems;
  final AddToCartUseCase addToCart;
  final RemoveFromCartUseCase removeFromCart;
  final ClearCartUseCase clearCart;
  final UpdateCartItemQuantityUseCase updateQty;
  final PlaceOrderUseCase placeOrder;
  final AuthProvider authProvider;

  CartProvider({
    required this.getCartItems,
    required this.addToCart,
    required this.removeFromCart,
    required this.clearCart,
    required this.updateQty,
    required this.placeOrder,
    required this.authProvider,
  });

  AuthProvider get _authProvider => authProvider;

  final CartRepo repo = sl<CartRepo>();

  List<CartItem> _items = [];
  List<CartItem> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  double get grandTotal =>
      _items.fold(0, (total, item) => total + item.price * item.quantity);

  final client = sl<APIClient>();
  // ─────────────────────────────────────────────────────────────────────

  Future<void> loadCart() async {
    _setLoading(true);
    _setError(null);

    final result = await getCartItems();
    result.fold(
      (failure) => _setError(failure.message),
      (cartItems) => _items = cartItems,
    );

    _setLoading(false);
  }

  Future<bool> add(CartItem item) async {
    final existingIndex = _items.indexWhere((e) => e.code == item.code);

    final CartItem updatedItem =
        existingIndex != -1
            ? _items[existingIndex].copyWith(
              quantity: _items[existingIndex].quantity + item.quantity,
              image: item.image ?? _items[existingIndex].image,
            )
            : item;

    // Try remote sync first
    final remoteResult = await repo.updateRemoteCart(updatedItem);
    final remoteFailed = remoteResult.fold((failure) {
      _setError("Remote sync failed: ${failure.message}");
      return true;
    }, (_) => false);

    if (remoteFailed) return false;

    // Update local cart if remote sync succeeded
    final result = await addToCart(updatedItem);
    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (updatedItems) {
        _items = updatedItems;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> remove(String code) async {
    final result = await removeFromCart(code);
    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (_) {
        _items.removeWhere((e) => e.code == code);
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> clear() async {
    await clearCart();
    _items = [];
    notifyListeners();
  }

  Future<void> updateQuantity(String code, int qty) async {
    await updateQty(code, qty);
    await loadCart();
  }

  bool containsProduct(String productCode) {
    return _items.any((item) => item.code == productCode);
  }

  // ─────────────────────────────────────────────────────────────────────
  /// Submit order directly using known shipping address
  Future<bool> submitCartAsSalesOrder({
    required String shippingAddressName,
  }) async {
    final user = _authProvider.user;

    if (user == null) {
      _setError('You must be logged in to place an order.');
      return false;
    }

    final payload = _buildOrderPayload(
      customer: user.username,
      address: shippingAddressName,
    );

    _setLoading(true);
    final result = await placeOrder(payload);
    _setLoading(false);

    return result.fold(
      (failure) {
        _setError('❌ Order failed: ${failure.message}');
        return false;
      },
      (_) {
        clear();
        return true;
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  OrderPayload _buildOrderPayload({
    required String customer,
    required String address,
    int docstatus = 1,
  }) {
    return OrderPayload(
      customer: customer,
      deliveryDate: DateTime.now().toIso8601String().split('T').first,
      docstatus: docstatus,
      shippingAddress: address,
      customerAddress: 'address-Shipping',
      addressType: 'Shipping',
      items: List<CartItem>.from(_items),
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }
}
