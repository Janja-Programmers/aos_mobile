import 'package:africaonlinestores/app/bootstrap/app_bootstrap_controller.dart';
import 'package:africaonlinestores/app/bootstrap/app_bootstrap_state.dart';
import 'package:africaonlinestores/app/splash/splash_screen.dart';
import 'package:africaonlinestores/core/routing/app_shell.dart';
import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/routing/helpers/route_guards.dart';
import 'package:africaonlinestores/core/routing/helpers/route_observer.dart';
import 'package:africaonlinestores/features/account/shared/routing/account_routes.dart';
import 'package:africaonlinestores/features/activity/navigation/activity_routes.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/pickers/select_category_screen.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/pickers/select_location_screen.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/screens/ad_form_screen.dart';
import 'package:africaonlinestores/features/ads/ads_report/presentation/report_ad_screen.dart';
import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/auth/shared/routing/auth_routes.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/catalog/shared/routing/catalog_routes.dart';
import 'package:africaonlinestores/features/connect/calls/navigation/call_routes.dart';
import 'package:africaonlinestores/features/connect/chats/navigation/chat_routes.dart';
import 'package:africaonlinestores/features/connect/routing/connect_routes.dart';
import 'package:africaonlinestores/features/home/presentation/screens/ad_details_screen.dart';
import 'package:africaonlinestores/features/live/navigation/live_routes.dart';
import 'package:africaonlinestores/features/maps/navigation/maps_routes.dart';
import 'package:africaonlinestores/features/notifications/navigation/notification_routes.dart';
import 'package:africaonlinestores/features/onboarding/screens/onboarding_screen.dart';
import 'package:africaonlinestores/features/reviews/application/navigation/reviews_routes.dart';
import 'package:africaonlinestores/features/search/shared/routing/search_routes.dart';
import 'package:africaonlinestores/features/sellers/navigation/seller_routes.dart';
import 'package:africaonlinestores/features/sellers/presentation/start_selling_screen.dart';
import 'package:africaonlinestores/features/shorts/shared/navigation/feeds_routes.dart';
import 'package:africaonlinestores/features/shorts/shared/navigation/shorts_routes.dart';
import 'package:africaonlinestores/features/social/navigation/social_navigation.dart';
import 'package:africaonlinestores/shared/enums/ads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final _routerRefreshNotifierProvider = Provider<_RouterRefreshNotifier>((ref) {
  final notifier = _RouterRefreshNotifier();

  ref.listen<AppBootstrapState>(appBootstrapProvider, (_, _) {
    notifier.refresh();
  });
  ref.listen<AuthState>(authControllerProvider, (_, _) {
    notifier.refresh();
  });
  ref.onDispose(notifier.dispose);

  return notifier;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final routerRefreshNotifier = ref.watch(_routerRefreshNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: routerRefreshNotifier,

    initialLocation: AppRoutes.splash,

    observers: [routeObserver],

    routes: [
      ...AuthRoutes.routes(),
      ...CallRoutes.routes(),
      ...ChatRoutes.routes(),
      ...ConnectScreenRoutes.routes(),
      ...LiveRoutes.routes(),
      ...MapsRoutes.routes(),
      ...NotificationsRoutes.routes(),
      ...ActivityRoutes.routes(),
      ...ReviewsRoutes.routes(),
      ...SearchRoutes.routes(),
      ...SellerRoutes.routes(),
      ...SocialRoutes.routes(),
      ...ShortsRoutes.routes(rootNavigatorKey: _rootNavigatorKey),

      GoRoute(
        name: AppRoutes.nOnboarding,
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      GoRoute(
        name: AppRoutes.nSplash,
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      /// CREATE AD
      GoRoute(
        name: AppRoutes.nCreateAd,
        path: AppRoutes.createAd,
        builder: (context, state) {
          final adId = state.uri.queryParameters['adId'];
          final draftId = state.uri.queryParameters['draftId'];
          final statusStr = state.uri.queryParameters['status'];

          AdStatus? status;

          if (statusStr != null) {
            status = AdStatus.values.firstWhere(
              (e) => e.name == statusStr,
              orElse: () => AdStatus.reviewing,
            );
          }

          final mode = adId != null ? AdFormMode.edit : AdFormMode.create;

          return AdFormScreen(
            mode: mode,
            adId: adId,
            draftId: draftId,
            status: status,
          );
        },
      ),

      /// AD DETAIL
      GoRoute(
        name: AppRoutes.nAdDetails,
        path: AppRoutes.adDetails,
        builder: (context, state) => AdDetailsScreen(id: _param(state, 'id')),
      ),

      /// CATEGORY PICKER
      GoRoute(
        name: AppRoutes.nSelectCategory,
        path: AppRoutes.selectCategory,
        builder: (context, state) {
          final extra = state.extra;
          CategoryNode? parent;

          if (extra is CategoryNode) {
            parent = extra;
          } else if (extra is Map) {
            final initialParent = extra['initialParent'];
            final openChildren = extra['openChildren'] == true;
            if (openChildren && initialParent is CategoryNode) {
              parent = initialParent;
            }
          }

          return SelectCategoryScreen(parent: parent);
        },
      ),

      /// LOCATION PICKER
      GoRoute(
        name: AppRoutes.nSelectLocation,
        path: AppRoutes.selectLocation,
        builder: (context, state) {
          final showAllLocations = (state.extra as bool?) ?? true;

          return SelectLocationScreen(showAllLocations: showAllLocations);
        },
      ),

      // REPORT Ad
      GoRoute(
        name: AppRoutes.nReportAd,
        path: AppRoutes.reportAd,
        builder: (context, state) {
          final adId = state.pathParameters['adId'];

          if (adId == null || adId.isEmpty) {
            return const Scaffold(body: Center(child: Text('Missing adId')));
          }

          return ReportAdScreen(adId: adId);
        },
      ),

      /// MAIN SHELL
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppShell(location: state.matchedLocation, child: child);
        },
        routes: [
          ...AdsRoutes.routes(),
          ...CatalogRoutes.routes(),
          ...AccountRoutes.routes(),
          ...FeedsRoutes.routes(),

          GoRoute(
            name: AppRoutes.nStartSelling,
            path: AppRoutes.startSelling,
            builder: (context, state) => const StartSellingScreen(),
          ),
        ],
      ),
    ],

    redirect: (context, state) {
      final bootstrap = ref.read(appBootstrapProvider);
      final auth = ref.read(authControllerProvider);
      final matchedLocation = state.matchedLocation;
      final currentLocation = state.uri.toString();

      if (!bootstrap.isReady) {
        return AppRoutes.splash;
      }

      if (auth is AuthLoading) {
        return AppRoutes.splash;
      }

      if (matchedLocation == AppRoutes.splash) {
        if (!bootstrap.onboardingCompleted) {
          return AppRoutes.onboarding;
        }
        return AppRoutes.home;
      }

      final isOnboarding = RouteGuards.isOnboarding(matchedLocation);

      if (!bootstrap.onboardingCompleted && !isOnboarding) {
        return AppRoutes.onboarding;
      }

      if (bootstrap.onboardingCompleted && isOnboarding) {
        return AppRoutes.home;
      }

      final isAuthRoute = RouteGuards.isAuthRoute(matchedLocation);
      final isProtected = RouteGuards.isProtectedRoute(currentLocation);

      if (auth is AuthGuest && isProtected) {
        if (isAuthRoute) return null;

        final encodedLocation = Uri.encodeComponent(currentLocation);
        return '${AppRoutes.login}?redirect=$encodedLocation';
      }

      if (auth is AuthAuthenticated && isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
  );
});

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() {
    notifyListeners();
  }
}

String _param(GoRouterState state, String key) =>
    Uri.decodeComponent(state.pathParameters[key] ?? '');
