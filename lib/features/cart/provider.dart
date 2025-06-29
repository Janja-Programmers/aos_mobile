
import 'package:flutter/material.dart';
import 'package:ownashop/core/utils/logger.dart';

import '/core/di/service_locator.dart';

import '../order/domain/sales_order.dart';
import '../order/domain/usecases.dart';
import '../address/data/datasource/local.dart';

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

  List<CartItem> _items = [];
  List<CartItem> get items => _items;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  double get grandTotal =>
      _items.fold(0, (total, item) => total + item.price * item.quantity);

  Future<void> loadCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final cartModels = await getCartItems();
    cartModels.fold(
      (failure) => _error = failure.message,
      (items) => _items = items,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> add(CartItem item) async {
    final result = await addToCart(item);
    return result.fold(
      (failure) {
        _error = failure.message;
        return false;
      },
      (updatedList) {
        _items = updatedList;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> remove(String code) async {
    final result = await removeFromCart(code);
    return result.fold(
      (failure) {
        _error = failure.message;
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
    await loadCart();
  }

  Future<void> updateQuantity(String code, int qty) async {
    await updateQty(code, qty);
    await loadCart();
  }

  Future<void> submitOrderWithExistingOrRedirect({
    required String customer,
    required VoidCallback openShippingForm,
    required Function(String addressName) onSuccess,
  }) async {
    _error = null;
    notifyListeners();

    try {
      final local = sl<LocalAddressRepository>();
      final addresses = await local.getAddressesForCustomer(customer);

      if (addresses.isEmpty) {
        openShippingForm();
        return;
      }

      final fullAddressName = "$customer-Shipping";

      final payload = OrderPayload(
        customer: customer,
        deliveryDate: DateTime.now().toIso8601String().split('T').first,
        items: _items,
        shippingAddress: fullAddressName,
        customerAddress: fullAddressName,
        addressType: "Shipping",
      );

      appLogger.i(
        'Placing order from PROVIDER.DART with $fullAddressName and PAYLOAD:$payload',
      );

      final result = await placeOrder(payload);

      result.fold(
        (failure) {
          _error = failure.message;
          notifyListeners();
        },
        (_) {
          appLogger.i('Placing order from PROVIDER.DART with RESULT:$result');
          clear();
          onSuccess(fullAddressName);
        },
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  bool containsProduct(String productCode) {
    return _items.any((item) => item.code == productCode);
  }
}
