import 'package:go_router/go_router.dart';

// Auth
import '/screens/settings/privacy.dart';
import '/screens/settings/tac.dart';
import '/screens/auth/auth_provider.dart';
import '/screens/auth/screens/login_screen.dart';
import '/screens/auth/screens/register_screen.dart';

// Seller
import '/features/product/domain/product.dart';
import '/screens/supplier/product/item_screen.dart';
import '/screens/supplier/dashboard/dashboard.dart';
import '/screens/supplier/product/update_item_screen.dart';
import '/screens/customer/web-items/screens/detail_screen.dart';
import '/screens/supplier/order/sales_order_list_screen.dart';
import '/screens/supplier/invoice/detail_screen.dart';
import '/screens/supplier/d_note/delivery_note_list_screen.dart';
import '/screens/supplier/order/order_detail_screen.dart';
import '/screens/supplier/d_note/delivery_note_detail_screen.dart';
import '/screens/supplier/invoice/list_screen.dart';

import '/features/stock/domain/entity/stock.dart';
import '/screens/supplier/stock/create_stock_screen.dart';
import '/screens/supplier/stock/stock_list_screen.dart';
import '/screens/supplier/stock/stock_detail_screen.dart';

// Customer
import '/features/order/domain/sales_order.dart';
import '/screens/customer/web-items/screens/list_screen.dart';
import '/screens/customer/wishlist/wishlist_screen.dart';
import '/screens/customer/cart/cart_screen.dart';
import '/screens/customer/address/shipping_address_form.dart';
import '/screens/customer/orders/order_detail.dart';
import '/screens/customer/orders/order_list.dart';

// Helper Pages
import '/screens/settings/settings_page.dart';

class AppRouter {
  final AuthProvider auth;

  AppRouter(this.auth);

  late final GoRouter router = GoRouter(
    refreshListenable: auth,
    initialLocation: '/login',
    redirect: (context, state) {
      final loggedIn = auth.isLoggedIn;

      // Checks if the current path is /login or /register
      final loggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // 🚫 Not logged in, and trying to go to any protected page
      if (!loggedIn && !loggingIn) {
        auth.setReturnTo(
          state.matchedLocation,
        ); // remember where they wanted to go
        return '/login';
      }

      // ✅ Logged in, but trying to go to /login or /register → redirect to home
      if (loggedIn && loggingIn) return auth.defaultHome;

      // ✅ No redirect needed
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

      // PRODUCTS ROUTES
      // CREATE ROUTE
      GoRoute(
        path: '/add-item',
        builder: (context, state) => const AddItemScreen(),
      ),

      // READ ROUTE
      GoRoute(path: '/items', builder: (context, state) => ItemScreen()),

      // UPDATE ROUTE
      GoRoute(
        path: '/edit-item/:name',
        builder: (context, state) {
          final product = state.extra as Product;
          return AddItemScreen(product: product);
        },
      ),

      // SALES ORDER ROUTES
      GoRoute(
        path: '/create-stock-entry',
        builder: (context, state) => const CreateStockEntryScreen(),
      ),

      // Sales Order List
      GoRoute(
        path: '/sales-orders',
        builder: (context, state) => const SalesOrderListScreen(),
      ),

      // Sales Order Detail
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

      // INVOICE ROUTES
      GoRoute(
        path: '/invoices',
        builder: (context, state) => const SalesInvoiceListScreen(),
      ),

      GoRoute(
        path: '/invoice/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SalesInvoiceDetailScreen(orderId: id);
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
        path: '/product/:itemCode',
        builder: (context, state) {
          final itemCode = state.pathParameters['itemCode']!;
          return ProductDetailScreen(itemCode: itemCode);
        },
      ),

      // Shipping Address
      GoRoute(
        path: '/shipping-address',
        builder: (_, _) => const ShippingAddressForm(),
      ),

      // Past Orders
      GoRoute(path: '/past-orders', builder: (_, _) => const OrderScreen()),
      GoRoute(
        path: '/order-detail',
        builder: (context, state) {
          final order = state.extra as SalesOrder;
          return CustomerSalesOrderDetailScreen(order: order);
        },
      ),

      // Core Routes
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),

      GoRoute(path: '/terms', builder: (context, state) => const TermsPage()),

      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyPage(),
      ),
    ],
  );
}
