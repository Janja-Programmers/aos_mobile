import 'package:go_router/go_router.dart';

// Auth
import '/features/product/domain/product.dart';
import '/features/auth/presentation/auth_provider.dart';
import '/features/auth/presentation/screens/login_screen.dart';
import '/features/auth/presentation/screens/register_screen.dart';

// Customer
import '/screens/customer/products/screens/product_list_screen.dart';
import '/screens/customer/products/screens/product_detail_screen.dart';
import '/screens/customer/wishlist/presentation/wishlist_screen.dart';
import '/screens/customer/cart/cart_screen.dart';
import '/screens/customer/address/shipping_address_form.dart';
// import '/features/website/domain/webitem.dart';

// Seller
import '/screens/supplier/dashboard/dashboard.dart';
import '/screens/supplier/item/item_screen.dart';
import '/screens/supplier/item/item_detail.dart';
import '/screens/supplier/website/web_item_list_screen.dart';
import '/screens/supplier/price/screens/item_price_list.dart';
import '/screens/supplier/order/sales_order_list_screen.dart';
import '/screens/supplier/d_note/delivery_note_list_screen.dart';
import '/screens/supplier/stock/stock_entry_list_screen.dart';

class AppRouter {
  final AuthProvider auth;

  AppRouter(this.auth);

  late final GoRouter router = GoRouter(
    refreshListenable: auth,
    initialLocation: '/login',
    redirect: (context, state) {
      final loggedIn = auth.isLoggedIn;
      final loggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) {
        final target = auth.redirectPath ?? '/';
        auth.clearRedirect();
        return target;
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),

      GoRoute(
        path: '/wishlist',
        builder: (context, state) => const WishlistScreen(),
      ),

      // SELLER ROUTES
      // Dashboard
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const SellerDashboard(),
      ),
      // Items
      GoRoute(path: '/items', builder: (context, state) => ItemScreen()),
      // Item Detail
      GoRoute(
        path: '/item-detail/:name',
        builder: (context, state) {
          final name = state.pathParameters['name']!;
          return ItemDetailScreen(itemName: name);
        },
      ),
      // Item Price
      GoRoute(
        path: '/item-price',
        builder: (context, state) => const ItemPriceScreen(),
      ),
      // Item Price Detail
      GoRoute(
        path: '/item-price/:name',
        builder: (context, state) {
          // final itemCode = state.pathParameters['itemCode'];
          // if (itemCode == null) {
          //   throw Exception('Invalid item price');
          // }
          return ItemPriceScreen();
        },
      ),
      // Website Items
      GoRoute(
        path: '/web-items',
        builder: (context, state) => const WebsiteItemListScreen(),
      ),
      // Sales Order
      GoRoute(
        path: '/sales-orders',
        builder: (context, state) => const SalesOrderListScreen(),
      ),
      // Delivery Note
      GoRoute(
        path: '/delivery-notes',
        builder: (context, state) => const DeliveryNoteListScreen(),
      ),

      // STOCK ROUTES
      GoRoute(
        path: '/stock-entry',
        builder: (context, state) => const StockEntryScreen(),
      ),

      // CUSTOMER ROUTES
      // All Products
      GoRoute(
        path: '/',
        builder: (context, state) => const ProductListScreen(),
      ),
      // Product Details
      GoRoute(
        path: '/product/:name',
        builder: (context, state) {
          final product = state.extra as Product;
          return ProductDetailScreen(product: product);
        },
      ),
      // Shipping Address
      GoRoute(
        path: '/shipping-address',
        builder: (_, _) => const ShippingAddressForm(),
      ),
    ],
  );
}
