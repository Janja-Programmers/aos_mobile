import '../domain/cart.dart';
import '../domain/repo.dart';

import 'local.dart';
import 'model.dart';

class CartRepoImpl implements CartRepo {
  final CartLocalDataSource local;
  CartRepoImpl(this.local);

  @override
  Future<void> addItem(CartItem item) async {
    final model = CartItemModel(
      code: item.code,
      name: item.name,
      price: item.price,
      quantity: item.quantity,
    );
    await local.insert(model);
  }

  @override
  Future<List<CartItem>> getItems() async => local.getAll();

  @override
  Future<void> removeItem(String code) async => local.delete(code);

  @override
  Future<void> clearCart() async => local.clear();

  @override
  Future<void> updateQuantity(String code, int quantity) async =>
      local.updateQuantity(code, quantity);
}
