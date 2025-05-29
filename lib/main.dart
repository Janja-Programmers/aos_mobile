import 'package:flutter/material.dart';
import './app.dart';

// Items
import 'features/item/data/datasource/item_local_datasource.dart';
import 'features/item/data/item_repo_impl.dart';
import 'features/item/domain/usecases/get_items.dart';
import 'features/item/domain/usecases/create_item.dart';

// Auth
import 'features/auth/data/auth_local_datasource.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login.dart';
import 'features/auth/domain/usecases/register.dart';

// Wishlist
import 'features/customer/wishlist/domain/usecases/add_to_wishlist.dart';
import 'features/customer/wishlist/domain/usecases/remove_from_wishlist.dart';
import 'features/customer/wishlist/domain/usecases/get_wishlist.dart';
import 'features/customer/wishlist/data/wishlist_local_data_source.dart';
import 'features/customer/wishlist/data/wishlist_repository_impl.dart';

// Cart
import 'features/customer/cart/domain/usecases/clear_cart.dart';
import 'features/customer/cart/domain/usecases/update_cart_quantity.dart';
import 'features/customer/cart/domain/usecases/add_to_cart.dart';
import 'features/customer/cart/domain/usecases/get_cart.dart';
import 'features/customer/cart/domain/usecases/remove_from_cart.dart';
import 'features/customer/cart/data/cart_local_data_source.dart';
import 'features/customer/cart/data/cart_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Item setup
  final itemLocalDataSource = ItemLocalDataSource();
  final itemRepo = ItemRepositoryImpl(itemLocalDataSource);

  // Wishlist setup
  final wishlistLocal = WishlistLocalDataSourceImpl();
  final wishlistRepo = WishlistRepositoryImpl(wishlistLocal);

  // Cart setup
  final cartLocal = CartLocalDataSourceImpl();
  final cartRepo = CartRepositoryImpl(cartLocal, localDataSource: cartLocal);

  // Auth setup
  final authLocal = AuthLocalDataSource();
  final authRepo = AuthRepositoryImpl(authLocal);
  final loginUser = LoginUser(authRepo);
  final registerUser = RegisterUser(authRepo);

  runApp(
    App(
      // Items
      getItems: GetItems(itemRepo),
      createItem: CreateItem(itemRepo),

      // Wishlist
      getWishlist: GetWishlist(wishlistRepo),
      addToWishlist: AddToWishlist(wishlistRepo),
      removeFromWishlist: RemoveFromWishlist(wishlistRepo),
      // Cart
      getCart: GetCart(cartRepo),
      addToCart: AddToCart(cartRepo),
      removeFromCart: RemoveFromCart(cartRepo),
      updateCartQuantity: UpdateCartQuantity(cartRepo),
      clearCart: ClearCart(cartRepo),
      // Auth
      loginUser: loginUser,
      registerUser: registerUser,
    ),
  );
}
