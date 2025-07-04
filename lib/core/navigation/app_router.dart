import 'package:go_router/go_router.dart';
// Auth
import '/features/product/domain/product.dart';
import '/features/auth/presentation/auth_provider.dart';
import '/features/auth/presentation/screens/login_screen.dart';
import '/features/auth/presentation/screens/register_screen.dart';

// Customer
import '/screens/customer/products/screens/product_list_screen.dart';
import '/screens/customer/wishlist/presentation/wishlist_screen.dart';
import '/screens/customer/cart/cart_screen.dart';
import '/screens/customer/address/shipping_address_form.dart';

// Seller
import '/screens/customer/products/screens/product_detail_screen.dart';
import '../../screens/supplier/product/update_item_screen.dart';
import '/screens/supplier/dashboard/dashboard.dart';
import '/screens/supplier/product/item_screen.dart';
import '/screens/supplier/order/sales_order_list_screen.dart';
import '/screens/supplier/d_note/delivery_note_list_screen.dart';
import '/screens/supplier/order/order_detail_screen.dart';
import '/screens/supplier/d_note/delivery_note_detail_screen.dart';

import '/features/stock/domain/entity/stock.dart';
import '/screens/supplier/stock/create_stock_screen.dart';
import '/screens/supplier/stock/stock_list_screen.dart';
import '/screens/supplier/stock/stock_detail_screen.dart';

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

      if (!loggedIn && !loggingIn) {
        auth.setReturnTo(state.matchedLocation);
        return '/login';
      }

      if (loggedIn && loggingIn) return auth.defaultHome;

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

      // Sales Order
      GoRoute(
        path: '/sales-orders',
        builder: (context, state) => const SalesOrderListScreen(),
      ),
      GoRoute(
        path: '/sales-order/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return SalesOrderDetailScreen(orderId: orderId);
        },
      ),

      // Delivery Note
      GoRoute(
        path: '/delivery-notes',
        builder: (context, state) => const DeliveryNoteListScreen(),
      ),
      GoRoute(
        path: '/delivery-note/:id',
        builder: (context, state) {
          final noteId = state.pathParameters['id']!;
          return DeliveryNoteDetailScreen(noteId: noteId);
        },
      ),

      // STOCK ROUTES
      GoRoute(
        path: '/stock-entry',
        builder: (context, state) => const StockEntryScreen(),
      ),
      GoRoute(
        path: '/stock-entry/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return StockEntryDetailScreen(stockEntryName: id);
        },
      ),
      GoRoute(
        path: '/stock/edit',
        builder: (_, state) {
          final stockEntry = state.extra as StockEntry;
          return CreateStockEntryScreen(entry: stockEntry);
        },
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
          final productId = state.pathParameters['name'];
          if (productId == null) {
            throw Exception('Product ID is required');
          }
          return ProductDetailScreen(productId: productId);
        },
      ),

      GoRoute(
        path: '/add-item',
        builder: (context, state) {
          final product = state.extra as Product?;
          return AddItemScreen(product: product);
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
