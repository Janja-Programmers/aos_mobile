import 'package:amani_mall/features/auth/domain/user.dart';
import 'package:go_router/go_router.dart';
import '../../features/item/presentation/item_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/customer/wishlist/presentation/wishlist_screen.dart';
import '../../features/customer/cart/presentation/cart_screen.dart';
import '../../features/supplier/dashboard/dashboard.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SellerDashboard()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

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
      builder: (context, state) {
        final user = state.extra;
        if (user is! User || user.id == null) {
          throw Exception(
            'User object with valid ID must be passed via state.extra',
          );
        }
        return ItemScreen(userId: user.id!);
      },
    ),
  ],
);
