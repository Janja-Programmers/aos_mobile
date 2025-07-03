import 'package:flutter/material.dart';
import 'package:ownashop/core/utils/api_client.dart';

import '/core/utils/logger.dart';
import '/core/di/service_locator.dart';

import '/features/auth/presentation/auth_provider.dart';
import '/features/address/data/datasource/local.dart';

import '../order/domain/sales_order.dart';
import '../order/domain/usecases.dart';

import 'domain/cart.dart';
import 'domain/usecase.dart';

class CartProvider with ChangeNotifier {
  final GetCartItemsUseCase getCartItems;
  final AddToCartUseCase addToCart;
  final RemoveFromCartUseCase removeFromCart;
  final ClearCartUseCase clearCart;
  final UpdateCartItemQuantityUseCase updateQty;
  final PlaceOrderUseCase placeOrder;

  CartProvider({
    required this.getCartItems,
    required this.addToCart,
    required this.removeFromCart,
    required this.clearCart,
    required this.updateQty,
    required this.placeOrder,
  });

  final _authProvider = sl<AuthProvider>();
  final _localAddressRepo = sl<LocalAddressRepository>();

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
    final result = await addToCart(item);
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
  Future<void> submitCartAsSalesOrder({
    required String shippingAddressName,
  }) async {
    final user = _authProvider.user;
    if (user == null) {
      _setError('You must be logged in to place an order.');
      return;
    }

    final payload = _buildOrderPayload(
      customer: user.username,
      address: shippingAddressName,
    );

    appLogger.i('📦 SUBMITTING ORDER PAYLOAD: ${payload.toJson()}');

    _setLoading(true);
    final result = await placeOrder(payload);

    _setLoading(false);

    result.fold((failure) => _setError('❌ Order failed: ${failure.message}'), (
      _,
    ) {
      appLogger.i('✅ Order placed successfully');
      clear();
    });
  }

  // ─────────────────────────────────────────────────────────────────────
  /// Handles case where address may not yet exist
  Future<void> submitCartWithAutoAddress({
    required String customer,
    required VoidCallback openShippingForm,
    required void Function(String addressName) onSuccess,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final addresses = await _localAddressRepo.getAddressesForCustomer(
        customer,
      );

      if (addresses.isEmpty) {
        _setLoading(false);
        openShippingForm();
        return;
      }

      final selectedAddress = addresses.first.title;
      final payload = _buildOrderPayload(
        customer: customer,
        address: selectedAddress,
      );

      appLogger.i('🛒 AUTO-ORDER using address: $selectedAddress');
      appLogger.i('📦 PAYLOAD: ${payload.toJson()}');

      final result = await placeOrder(payload);

      _setLoading(false);

      result.fold((failure) => _setError(failure.message), (_) {
        appLogger.i('✅ Order placed successfully');
        clear();
        onSuccess(selectedAddress);
      });
    } catch (e) {
      _setError('Unexpected error: $e');
      _setLoading(false);
    }
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
