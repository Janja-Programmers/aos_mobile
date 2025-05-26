import '../domain/cart_item.dart';
import '../domain/cart_repository.dart';
import 'cart_local_data_source.dart';
import 'cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl(CartLocalDataSourceImpl cartLocal, {required this.localDataSource});

  Future<List<CartItem>> getCart() async {
    return localDataSource.getCartItems();
  }

  @override
  Future<List<CartItem>> getCartItems() async {
    return await getCart();
  }

  @override
  Future<void> addToCart(CartItem item) async {
    final items = await localDataSource.getCartItems();
    final index = items.indexWhere((e) => e.id == item.id);

    if (index != -1) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(
        CartItemModel(
          id: item.id,
          title: item.title,
          price: item.price,
          imageUrl: item.imageUrl,
          quantity: 1,
        ),
      );
    }

    await localDataSource.saveCartItems(items);
  }

  @override
  Future<void> updateCartQuantity(String id, int quantity) async {
    final items = await localDataSource.getCartItems();
    final index = items.indexWhere((e) => e.id == id);

    if (index != -1) {
      if (quantity < 1) {
        items.removeAt(index);
      } else {
        items[index] = items[index].copyWith(quantity: quantity);
      }
      await localDataSource.saveCartItems(items);
    }
  }

  @override
  Future<void> removeFromCart(String id) async {
    final items = await localDataSource.getCartItems();
    items.removeWhere((e) => e.id == id);
    await localDataSource.saveCartItems(items);
  }

  @override
  Future<void> clearCart() async {
    await localDataSource.saveCartItems([]);
  }
}
