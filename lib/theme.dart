// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:africaonlinestores/core/localization/locale_controller.dart';
// import 'package:africaonlinestores/core/routing/app_router.dart';
// import 'package:africaonlinestores/core/theme/app_theme.dart';
// import 'package:africaonlinestores/core/theme/theme_controller.dart';
// import 'package:africaonlinestores/core/theme/theme_prefs.dart';
// import 'package:africaonlinestores/core/utils/local_resolver.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Read saved theme (synchronous-ish, before runApp)
//   final savedTheme = await ThemePrefs.readThemeMode();
//   final initialTheme = savedTheme ?? ThemeMode.light;

//   runApp(
//     ProviderScope(
//       overrides: [
//         themeModeProvider.overrideWith(
//           () => PreloadedThemeController(initialTheme),
//         ),
//       ],
//       child: const AOSApp(),
//     ),
//   );
// }

// class AOSApp extends ConsumerWidget {
//   const AOSApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final router = ref.watch(appRouterProvider);
//     final themeModeAsync = ref.watch(themeModeProvider);
//     final localeAsync = ref.watch(localeControllerProvider);

//     return themeModeAsync.when(
//       loading: () => const SizedBox.shrink(),
//       error: (_, _) => const SizedBox.shrink(),
//       data: (themeMode) {
//         return MaterialApp.router(
//           title: 'Africa Online Stores',
//           theme: AppTheme.light(),
//           darkTheme: AppTheme.dark(),
//           themeMode: themeMode,
//           locale: resolveLocale(localeAsync),
//           localizationsDelegates: const [
//             ...GlobalMaterialLocalizations.delegates,
//             GlobalCupertinoLocalizations.delegate,
//             GlobalWidgetsLocalizations.delegate,
//           ],
//           supportedLocales: const [
//             Locale('en'),
//             Locale('sw'),
//             Locale('fr'),
//             Locale('ar'),
//           ],
//           routerConfig: router,
//           debugShowCheckedModeBanner: false,
//         );
//       },
//     );
//   }
// }
