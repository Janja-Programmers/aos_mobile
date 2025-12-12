import 'package:go_router/go_router.dart';

// Auth
import '/screens/settings/privacy.dart';
import '/screens/settings/tac.dart';
import '/screens/auth/auth_provider.dart';
import '/screens/auth/screens/login_screen.dart';
import '/screens/auth/screens/register_screen.dart';
import '/screens/auth/screens/reset_password.dart';

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
    initialLocation: '/',

    redirect: (context, state) {
      final loggedIn = auth.isLoggedIn;
      final loc = state.matchedLocation;

      // ---------- PUBLIC ROUTES ----------
      final publicRoutes = {
        '/', // Home / product list
        '/terms',
        '/privacy',
      };

      // Dynamic public routes
      final isPublic =
          publicRoutes.contains(loc) || loc.startsWith('/product/');

      // ---------- AUTH ROUTES ----------
      final authRoutes = {'/login', '/register', '/forgot-password'};
      final isAuthRoute = authRoutes.contains(loc);

      // ---------- REDIRECT RULES ----------

      // 1) Not logged in & trying to access protected route → Go login
      if (!loggedIn && !isPublic && !isAuthRoute) {
        auth.setReturnTo(loc);
        return '/login';
      }

      // 2) Logged in & trying to access login/register → Send home
      if (loggedIn && isAuthRoute) {
        return auth.defaultHome;
      }

      return null;
    },

    routes: [
      // ========== AUTH ==========
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordScreen(),
      ),

      // ========== PUBLIC ==========
      GoRoute(path: '/', builder: (_, _) => const ProductListScreen()),

      GoRoute(
        path: '/product/:itemCode',
        builder: (_, state) {
          final code = state.pathParameters['itemCode']!;
          final extra = state.extra as Map<String, dynamic>?;

          final stock =
              extra != null && extra['isStockItem'] != null
                  ? extra['isStockItem'] as bool
                  : false;

          return ProductDetailScreen(itemCode: code, isStockItem: stock);
        },
      ),

      GoRoute(path: '/terms', builder: (_, _) => const TermsPage()),
      GoRoute(path: '/privacy', builder: (_, _) => const PrivacyPage()),

      // ========== PROTECTED ==========
      GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),
      GoRoute(path: '/wishlist', builder: (_, _) => const WishlistScreen()),
      GoRoute(
        path: '/shipping-address',
        builder: (_, _) => const ShippingAddressForm(),
      ),
      GoRoute(path: '/past-orders', builder: (_, _) => const OrderScreen()),

      GoRoute(
        path: '/order-detail',
        builder: (_, state) {
          final order = state.extra as SalesOrder;
          return CustomerSalesOrderDetailScreen(order: order);
        },
      ),

      // CUSTOMER ROUTES
      // All Products
      GoRoute(
        path: '/',
        builder: (context, state) => const ProductListScreen(),
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

      // ---------- Seller Routes ----------
      GoRoute(path: '/dashboard', builder: (_, _) => const SellerDashboard()),
      GoRoute(path: '/add-item', builder: (_, _) => const AddItemScreen()),
      GoRoute(path: '/items', builder: (_, _) => ItemScreen()),

      GoRoute(
        path: '/edit-item/:name',
        builder: (_, state) {
          final product = state.extra as Product;
          return AddItemScreen(product: product);
        },
      ),

      GoRoute(
        path: '/create-stock-entry',
        builder: (_, _) => const CreateStockEntryScreen(),
      ),

      GoRoute(
        path: '/sales-orders',
        builder: (_, _) => const SalesOrderListScreen(),
      ),
      GoRoute(
        path: '/sales-order/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          return SalesOrderDetailScreen(orderId: id);
        },
      ),

      GoRoute(
        path: '/delivery-notes',
        builder: (_, _) => const DeliveryNoteListScreen(),
      ),
      GoRoute(
        path: '/delivery-note/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          return DeliveryNoteDetailScreen(noteId: id);
        },
      ),

      GoRoute(
        path: '/stock-entry',
        builder: (_, _) => const StockEntryScreen(),
      ),
      GoRoute(
        path: '/stock-entry/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          return StockEntryDetailScreen(stockEntryName: id);
        },
      ),
      GoRoute(
        path: '/stock/edit',
        builder: (_, state) {
          final stock = state.extra as StockEntry;
          return CreateStockEntryScreen(entry: stock);
        },
      ),

      GoRoute(
        path: '/invoices',
        builder: (_, _) => const SalesInvoiceListScreen(),
      ),
      GoRoute(
        path: '/invoice/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          return SalesInvoiceDetailScreen(invoiceId: id);
        },
      ),
    ],
  );
}
