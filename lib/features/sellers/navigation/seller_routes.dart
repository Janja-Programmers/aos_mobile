import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/sellers/domain/aos_seller.dart';
import 'package:africaonlinestores/features/sellers/location/presentation/screens/seller_location_screen.dart';
import 'package:africaonlinestores/features/sellers/presentation/my_storefront_screen.dart';
import 'package:africaonlinestores/features/sellers/presentation/seller_storefront_screen.dart';
import 'package:africaonlinestores/features/sellers/presentation/store_customization_screen.dart';
import 'package:africaonlinestores/features/verifications/presentation/verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SellerRoutes {
  const SellerRoutes._();

  static List<GoRoute> routes() => [..._publicRoutes, ..._privateRoutes];

  static final List<GoRoute> _publicRoutes = [
    // SELLER VERIFICATION ROUTE
    GoRoute(
      name: AppRoutes.nSellerVerification,
      path: AppRoutes.sellerVerification,
      builder: (context, state) => const VerificationScreen(),
    ),

    // SELLER STORE ROUTE
    GoRoute(
      name: AppRoutes.nSellerStore,
      path: AppRoutes.sellerStore,
      builder: (context, state) {
        final extra = state.extra;

        return SellerStorefrontScreen(
          sellerId: _param(state, 'sellerId'),
          initialSeller: extra is AOSSellerProfile ? extra : null,
        );
      },
    ),
  ];

  static final List<GoRoute> _privateRoutes = [
    /// CREATE / UPDATE STORE
    GoRoute(
      name: AppRoutes.nSellerCustomizeStore,
      path: AppRoutes.sellerCustomizeStore,
      builder: (context, state) {
        final sellerId = _param(state, 'sellerId');

        return StoreCustomizationScreen(sellerId: sellerId);
      },
    ),

    GoRoute(
      name: AppRoutes.nMyStoreFront,
      path: AppRoutes.myStoreFront,
      builder: (context, state) {
        return MyStorefrontScreen(sellerId: _param(state, 'sellerId'));
      },
    ),

    GoRoute(
      name: AppRoutes.nSellerLocation,
      path: AppRoutes.sellerLocation,
      builder: (context, state) => const SellerLocationScreen(),
    ),
  ];
}

class SellerNavigation {
  const SellerNavigation._();

  static void toSellerStore(
    BuildContext context,
    String sellerId, {
    AOSSellerProfile? seller,
  }) {
    context.pushNamed(
      AppRoutes.nSellerStore,
      pathParameters: {'sellerId': sellerId},
      extra: seller,
    );
  }

  static void toMyStoreFront(
    BuildContext context,
    String sellerId, {
    AOSSellerProfile? seller,
  }) {
    context.pushNamed(
      AppRoutes.nMyStoreFront,
      pathParameters: {'sellerId': sellerId},
    );
  }

  static void toSellerVerification(BuildContext context) {
    context.pushNamed(AppRoutes.nSellerVerification);
  }

  static Future<bool?> toCustomizeStore(BuildContext context, String sellerId) {
    return context.pushNamed<bool>(
      AppRoutes.nSellerCustomizeStore,
      pathParameters: {'sellerId': sellerId},
    );
  }

  static Future<bool?> toSellerLocation(BuildContext context) {
    return context.pushNamed<bool>(AppRoutes.nSellerLocation);
  }
}

String _param(GoRouterState state, String key) =>
    Uri.decodeComponent(state.pathParameters[key] ?? '');
