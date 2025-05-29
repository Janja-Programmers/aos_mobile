import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/themes.dart';
import '../core/navigation/app_router.dart';
import '../core/constants/strings.dart';

// Item Feature
import 'features/item/domain/usecases/get_items.dart';
import 'features/item/domain/usecases/create_item.dart';
import 'features/item/presentation/item_provider.dart';

// AUth Feature
import 'package:amani_mall/features/auth/presentation/auth_provider.dart';
import 'features/auth/domain/usecases/login.dart';
import 'features/auth/domain/usecases/register.dart';

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
  final GetWishlist getWishlist;
  final AddToWishlist addToWishlist;
  final RemoveFromWishlist removeFromWishlist;

  final GetCart getCart;
  final AddToCart addToCart;
  final RemoveFromCart removeFromCart;
  final UpdateCartQuantity updateCartQuantity;
  final ClearCart clearCart;

  final LoginUser loginUser;
  final RegisterUser registerUser;

  final GetItems getItems;
  final CreateItem createItem;

  const App({
    super.key,
    required this.getWishlist,
    required this.addToWishlist,
    required this.removeFromWishlist,
    required this.getCart,
    required this.addToCart,
    required this.removeFromCart,
    required this.updateCartQuantity,
    required this.clearCart,
    required this.loginUser,
    required this.registerUser,
    required this.getItems,
    required this.createItem,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
        ChangeNotifierProvider(
          create:
              (_) => AuthProvider(
                loginUser: loginUser,
                registerUser: registerUser,
              ),
        ),
        ChangeNotifierProvider(
          create:
              (_) => ItemProvider(
                createItemUsecase: createItem,
                getItemsUsecase: getItems,
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
