import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/app/bootstrap/app_bootstrap_controller.dart';
import 'package:africaonlinestores/app/splash/splash_screen.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/routing/app_shell.dart';
import 'package:africaonlinestores/core/routing/helpers/route_guards.dart';
import 'package:africaonlinestores/core/routing/helpers/route_observer.dart';

import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/auth/shared/routing/auth_routes.dart';

import 'package:africaonlinestores/features/account/shared/routing/account_routes.dart';

import 'package:africaonlinestores/features/ads/shared/routing/ads_routes.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/pickers/select_category_screen.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/pickers/select_location_screen.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/screens/ad_form_screen.dart';
import 'package:africaonlinestores/features/ads/ads_report/presentation/report_ad_screen.dart';

import 'package:africaonlinestores/features/catalog/shared/routing/catalog_routes.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/connect/calls/navigation/call_routes.dart';
import 'package:africaonlinestores/features/connect/chats/navigation/chat_routes.dart';
import 'package:africaonlinestores/features/connect/routing/connect_routes.dart';
import 'package:africaonlinestores/features/home/presentation/screens/ad_details_screen.dart';
import 'package:africaonlinestores/features/notifications/navigation/notification_routes.dart';

import 'package:africaonlinestores/features/live/navigation/live_routes.dart';
import 'package:africaonlinestores/features/onboarding/screens/onboarding_screen.dart';
import 'package:africaonlinestores/features/reviews/application/navigation/reviews_routes.dart';
import 'package:africaonlinestores/features/search/shared/routing/search_routes.dart';
import 'package:africaonlinestores/features/sellers/navigation/seller_routes.dart';
import 'package:africaonlinestores/features/sellers/presentation/start_selling_screen.dart';
import 'package:africaonlinestores/features/social/navigation/social_navigation.dart';
import 'package:africaonlinestores/features/shorts/shared/navigation/feeds_routes.dart';
import 'package:africaonlinestores/features/shorts/shared/navigation/shorts_routes.dart';

import 'package:africaonlinestores/shared/enums/ads.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final bootstrap = ref.watch(appBootstrapProvider);
  final auth = ref.watch(authControllerProvider);

  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,

    initialLocation: AppRoutes.splash,

    observers: [routeObserver],

    routes: [
      ...AuthRoutes.routes(),
      ...CallRoutes.routes(),
      ...ChatRoutes.routes(),
      ...ConnectScreenRoutes.routes(),
      ...LiveRoutes.routes(),
      ...NotificationsRoutes.routes(),
      ...ReviewsRoutes.routes(),
      ...SearchRoutes.routes(),
      ...SellerRoutes.routes(),
      ...SocialRoutes.routes(),
      ...ShortsRoutes.routes(rootNavigatorKey: rootNavigatorKey),

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

          final mode = adId != null || draftId != null
              ? AdFormMode.edit
              : AdFormMode.create;

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
          final parent = state.extra is CategoryNode
              ? state.extra as CategoryNode
              : null;

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
        navigatorKey: shellNavigatorKey,
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
      final location = state.matchedLocation;

      if (!bootstrap.isReady) {
        return AppRoutes.splash;
      }

      if (auth is AuthLoading) {
        return AppRoutes.splash;
      }

      if (location == AppRoutes.splash) {
        if (!bootstrap.onboardingCompleted) {
          return AppRoutes.onboarding;
        }
        return AppRoutes.home;
      }

      final isOnboarding = RouteGuards.isOnboarding(location);

      if (!bootstrap.onboardingCompleted && !isOnboarding) {
        return AppRoutes.onboarding;
      }

      if (bootstrap.onboardingCompleted && isOnboarding) {
        return AppRoutes.home;
      }

      final isAuthRoute = RouteGuards.isAuthRoute(location);
      final isProtected = RouteGuards.isProtectedRoute(location);

      if (auth is AuthGuest && isProtected) {
        if (isAuthRoute) return null;

        final encodedLocation = Uri.encodeComponent(location);
        return '${AppRoutes.login}?redirect=$encodedLocation';
      }

      if (auth is AuthAuthenticated && isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
  );
});

String _param(GoRouterState state, String key) =>
    Uri.decodeComponent(state.pathParameters[key] ?? '');
