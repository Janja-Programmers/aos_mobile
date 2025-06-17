import 'package:go_router/go_router.dart';

import '../di/service_locator.dart';

// Auth
import '/features/auth/presentation/auth_provider.dart';
import '/features/auth/presentation/screens/login_screen.dart';
import '/features/auth/presentation/screens/register_screen.dart';

// Customer
import '/screens/customer/products/screens/product_list_screen.dart';
import '/screens/customer/products/screens/product_detail_screen.dart';
import '/screens/customer/wishlist/presentation/wishlist_screen.dart';
import '/features/website/domain/webitem.dart';

// Seller
import '/screens/supplier/dashboard/dashboard.dart';
import '/screens/supplier/item/item_screen.dart';
import '/screens/supplier/item/item_detail.dart';
import '/screens/supplier/website/web_item_list_screen.dart';
import '/screens/supplier/price/screens/item_price_list.dart';
import '/screens/supplier/order/sales_order_list_screen.dart';
import '/features/stock/presentation/stock_entry_detail_screen.dart';
import '/features/stock/presentation/stock_entry_list_screen.dart';

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

    // SELLER ROUTES
    // Dashboard
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const SellerDashboard(),
    ),
    // Items
    GoRoute(path: '/items', builder: (context, state) => const ItemScreen()),
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

    // CUSTOMER ROUTES
    // All Products
    GoRoute(path: '/', builder: (context, state) => const ProductListScreen()),
    // Product Details
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final item = state.extra as WebsiteItem;
        return ProductDetailScreen(product: item);
      },
    ),
  ],
);
