import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/themes.dart';
import '../core/navigation/app_router.dart';
import '../core/constants/strings.dart';

// Product Feature
import 'features/shared/products/domain/usecases/get_product_details.dart';
import 'features/shared/products/domain/usecases/get_products.dart';
import 'features/customer/product/presentation/product_provider.dart';

// Wishlist Feature
import 'features/customer/wishlist/domain/usecases/add_to_wishlist.dart';
import 'features/customer/wishlist/domain/usecases/remove_from_wishlist.dart';
import 'features/customer/wishlist/domain/usecases/get_wishlist.dart';
import 'features/customer/wishlist/presentation/wishlist_provider.dart';

// Cart Feature
import 'features/customer/cart/domain/usecases/add_to_cart.dart';
import 'features/customer/cart/domain/usecases/get_cart.dart';
import 'features/customer/cart/domain/usecases/remove_from_cart.dart';
import 'features/customer/cart/domain/usecases/update_cart_quantity.dart';
import 'features/customer/cart/domain/usecases/clear_cart.dart';
import 'features/customer/cart/presentation/cart_provider.dart';

class App extends StatelessWidget {
  final GetProducts getProducts;
  final GetProductDetails getProductDetails;

  final GetWishlist getWishlist;
  final AddToWishlist addToWishlist;
  final RemoveFromWishlist removeFromWishlist;

  final GetCart getCart;
  final AddToCart addToCart;
  final RemoveFromCart removeFromCart;
  final UpdateCartQuantity updateCartQuantity;
  final ClearCart clearCart;

  const App({
    super.key,
    required this.getProducts,
    required this.getProductDetails,
    required this.getWishlist,
    required this.addToWishlist,
    required this.removeFromWishlist,
    required this.getCart,
    required this.addToCart,
    required this.removeFromCart,
    required this.updateCartQuantity,
    required this.clearCart,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create:
              (_) => ProductProvider(
                getProducts: getProducts,
                getProductDetails: getProductDetails,
              ),
        ),
        ChangeNotifierProvider(
          create:
              (_) => WishlistProvider(
                getWishlist: getWishlist,
                addToWishlist: addToWishlist,
                removeFromWishlist: removeFromWishlist,
              ),
        ),
        ChangeNotifierProvider(
          create:
              (_) => CartProvider(
                getCart: getCart,
                addToCart: addToCart,
                removeFromCart: removeFromCart,
                updateCartQuantity: updateCartQuantity,
                clearCart: clearCart,
              ),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        title: AppStrings.appName,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: ThemeMode.system,
      ),
    );
  }
}
