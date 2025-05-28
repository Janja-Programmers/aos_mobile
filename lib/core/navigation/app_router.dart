import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/shared/item/domain/item.dart';
import '../../features/supplier/item/presentation/screens/item_list_screen.dart';
import '../../features/supplier/item/presentation/screens/create_item_screen.dart';
import '../../features/supplier/item/presentation/screens/edit_item_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
// import '../../features/customer/product/presentation/screens/product_detail_screen.dart';
import '../../features/customer/product/presentation/screens/product_list_screen.dart';
import '../../features/customer/wishlist/presentation/wishlist_screen.dart';
import '../../features/customer/cart/presentation/cart_screen.dart';
import '../../features/supplier/dashboard/dashboard.dart';

final GoRouter router = GoRouter(
  initialLocation: '/register',
  routes: [
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductListScreen(),
    ),
    // GoRoute(
    //   builder: (context, state) {
    //   path: '/product/:id',
    //     final id = state.pathParameters['id']!;
    //     return ProductDetailScreen(productId: id);
    //   },
    // ),
    GoRoute(
      path: '/wishlist',
      builder: (context, state) => const WishlistScreen(),
    ),
    GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),

    // SELLER ROUTES
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const SellerDashboard(),
    ),
    GoRoute(
      path: '/items',
      builder: (context, state) => const ItemListScreen(),
    ),
    // GoRoute(
    //   path: '/items/:itemName',
    //   builder: (context, state) {
    //     final itemName = state.pathParameters['itemName']!;
    //     return ItemListScreen(itemName: itemName);
    //   },
    // ),
    GoRoute(
      path: 'item/new',
      builder: (context, state) => const CreateItemScreen(),
    ),
    GoRoute(
      path: 'item/:itemName',
      builder: (context, state) {
        final Item? item = state.extra as Item?;

        if (item == null) {
          // But here we’ll just throw
          throw Exception('Item object not passed via state.extra');
        }

        return EditItemScreen(item: item);
      },
    ),
  ],
);
