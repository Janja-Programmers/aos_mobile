import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/themes.dart';
import 'core/navigation/app_router.dart';
import 'core/constants/strings.dart';
import 'core/di/service_locator.dart';

// AUTH Feature
import 'features/auth/presentation/auth_provider.dart';

// PRODUCT Feature
import 'features/charts/presentation/provider.dart';
import 'features/product/provider.dart';
import 'screens/customer/web-items/utils/vendor_prov.dart';
import 'screens/customer/web-items/utils/vendor_utils.dart';

// ITEM Feature
import 'features/item/prov.dart';

// ITEMPRICE Feature
import 'features/itemPrice/prov.dart';

// SALESORDER Feature
import 'features/order/prov.dart';

// DELIVERYNOTE Feature
import 'features/d_note/prov.dart';

// STOCKENTRY Feature
import 'features/stock/providers/all.dart';
import 'features/stock/providers/read.dart';
import 'features/stock/providers/create.dart';

// CART Feature
import 'package:ownashop/features/cart/provider.dart';

// ADDRESS Feature
import '/features/address/provider.dart';

// WEBSITE Feature
import 'features/website/prov.dart';
import 'screens/supplier/product/controllers/add_item_controller.dart';

class App extends StatelessWidget {
  final AuthProvider auth;

  const App({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ChangeNotifierProvider(create: (_) => sl<WebsiteItemProv>()),
        ChangeNotifierProvider(create: (_) => sl<ProductProvider>()),
        ChangeNotifierProvider(create: (_) => sl<ItemProv>()),
        ChangeNotifierProvider(create: (_) => sl<ItemPriceProvider>()),
        ChangeNotifierProvider(create: (_) => sl<SalesOrderProvider>()),
        ChangeNotifierProvider(create: (_) => sl<DeliveryNoteProvider>()),
        ChangeNotifierProvider(create: (_) => sl<StockEntryProvider>()),
        ChangeNotifierProvider(create: (_) => sl<CreateStockEntryProvider>()),
        ChangeNotifierProvider(create: (_) => sl<StockEntryDetailProvider>()),
        ChangeNotifierProvider(create: (_) => sl<CartProvider>()),
        ChangeNotifierProvider(create: (_) => sl<AddressProvider>()),
        ChangeNotifierProvider(
          create: (_) => sl<SalesChartProvider>()..fetchChart(),
        ),
        ChangeNotifierProvider(
          create: (_) => VendorProvider(utils: sl<VendorUtils>()),
        ),
        ChangeNotifierProvider(
          create:
              (_) => AddItemController(
                provider: sl<ProductProvider>(),
                apiClient: sl(),
              ),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter(auth).router,
        title: AppStrings.appName,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: ThemeMode.light,
      ),
    );
  }
}
