import 'package:flutter/material.dart';
import './app.dart';

// Products
import 'features/products/domain/usecases/get_product_details.dart';
import 'features/products/domain/usecases/get_products.dart';
import 'features/products/data/product_remote_datasource.dart';
import 'features/products/data/product_repository_impl.dart';

// Wishlist
import 'features/wishlist/domain/usecases/add_to_wishlist.dart';
import 'features/wishlist/domain/usecases/remove_from_wishlist.dart';
import 'features/wishlist/domain/usecases/get_wishlist.dart';
import 'features/wishlist/data/wishlist_local_data_source.dart';
import 'features/wishlist/data/wishlist_repository_impl.dart';

// Cart
import 'features/cart/domain/usecases/clear_cart.dart';
import 'features/cart/domain/usecases/update_cart_quantity.dart';
import 'features/cart/domain/usecases/add_to_cart.dart';
import 'features/cart/domain/usecases/get_cart.dart';
import 'features/cart/domain/usecases/remove_from_cart.dart';
import 'features/cart/data/cart_local_data_source.dart';
import 'features/cart/data/cart_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Product setup
  final productRemote = ProductRemoteDataSourceImpl();
  final productRepo = ProductRepositoryImpl(productRemote);

  // Wishlist setup
  final wishlistLocal = WishlistLocalDataSourceImpl();
  final wishlistRepo = WishlistRepositoryImpl(wishlistLocal);

  // Cart setup
  final cartLocal = CartLocalDataSourceImpl();
  final cartRepo = CartRepositoryImpl(cartLocal, localDataSource: cartLocal);

  runApp(
    App(
      getProducts: GetProducts(productRepo),
      getProductDetails: GetProductDetails(productRepo),
      getWishlist: GetWishlist(wishlistRepo),
      addToWishlist: AddToWishlist(wishlistRepo),
      removeFromWishlist: RemoveFromWishlist(wishlistRepo),
      getCart: GetCart(cartRepo),
      addToCart: AddToCart(cartRepo),
      removeFromCart: RemoveFromCart(cartRepo),
      updateCartQuantity: UpdateCartQuantity(cartRepo),
      clearCart: ClearCart(cartRepo),
    ),
  );
}
