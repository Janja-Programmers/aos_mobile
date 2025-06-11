import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/constants/themes.dart';
import '/core/navigation/app_router.dart';
import '/core/constants/strings.dart';
import 'core/di/service_locator.dart';

// AUTH Feature
import 'features/auth/presentation/auth_provider.dart';

// ITEM Feature
import 'features/item/presentation/prov.dart';

// WEBITEM Feature
import 'features/website/presentation/prov.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => sl<WebsiteItemProv>()),
        ChangeNotifierProvider(create: (_) => sl<ItemProv>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        title: AppStrings.appName,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: ThemeMode.system,
      ),
    );
  }
}
