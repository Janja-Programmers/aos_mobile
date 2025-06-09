import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/customer/products/screens/product_list_screen.dart';
import '../../features/item/presentation/item_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/customer/wishlist/presentation/wishlist_screen.dart';
// import '../../features/customer/cart/presentation/cart_screen.dart';
import '../../features/stock/presentation/stock_entry_detail_screen.dart';
import '../../features/stock/presentation/stock_entry_list_screen.dart';
import '../../features/supplier/dashboard/dashboard.dart';
import '../../features/website/presentation/web_item_list_screen.dart';
import '../di/service_locator.dart';

final authProvider = sl<AuthProvider>();

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    GoRoute(
      path: '/wishlist',
      builder: (context, state) => const WishlistScreen(),
    ),
    // GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),

    // SELLER ROUTES
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const SellerDashboard(),
    ),
    GoRoute(path: '/items', builder: (context, state) => const ItemScreen()),

    // STOCK ROUTES
    GoRoute(
      path: '/stock',
      builder: (context, state) => const StockEntryListScreen(),
    ),

    GoRoute(
      path: '/stock/:id',
      builder: (context, state) {
        final stockEntryId = int.tryParse(state.pathParameters['id'] ?? '');
        if (stockEntryId == null) {
          throw Exception('Invalid stock entry ID');
        }
        return StockEntryDetailScreen(stockEntryId: stockEntryId);
      },
    ),

    // WEBSITE ITEM ROUTES
    GoRoute(
      path: '/web-items',
      builder: (context, state) => const WebsiteItemListScreen(),
    ),

    // CUSTOMER ROUTES
    // All Products
    GoRoute(path: '/', builder: (context, state) => const ProductListScreen()),
  ],
);
