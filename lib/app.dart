import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/themes.dart';
import 'core/navigation/app_router.dart';
import 'core/constants/strings.dart';
import 'core/di/service_locator.dart';

// AUTH Feature
import 'features/auth/presentation/auth_provider.dart';

// ITEM Feature
import 'features/item/prov.dart';

// WEBITEM Feature
import 'features/website/prov.dart';

// ITEMPRICE Feature
import 'features/itemPrice/prov.dart';

// SALESORDER Feature
import 'features/order/prov.dart';

// DELIVERYNOTE Feature
import 'features/d_note/prov.dart';

// STOCKENTRY Feature
import 'features/stock/prov.dart';

// CART Feature
import 'package:ownashop/features/cart/provider.dart';

class App extends StatelessWidget {
  final AuthProvider auth;

  const App({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ChangeNotifierProvider(create: (_) => sl<WebsiteItemProv>()),
        ChangeNotifierProvider(create: (_) => sl<ItemProv>()),
        ChangeNotifierProvider(create: (_) => sl<ItemPriceProvider>()),
        ChangeNotifierProvider(create: (_) => sl<SalesOrderProvider>()),
        ChangeNotifierProvider(create: (_) => sl<DeliveryNoteProvider>()),
        ChangeNotifierProvider(create: (_) => sl<StockEntryProvider>()),
        ChangeNotifierProvider(create: (_) => sl<CartProvider>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter(auth).router, // 👈 inject auth here
        title: AppStrings.appName,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: ThemeMode.system,
      ),
    );
  }
}
