import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';
import 'package:africaonlinestores/features/seller/presentation/seller_store_screen.dart';

class SellerRoutes {
  const SellerRoutes._();

  static List<GoRoute> routes() => [..._publicRoutes];

  static final List<GoRoute> _publicRoutes = [
    // REVIEW ROUTE
    GoRoute(
      name: AppRoutes.nSellerStore,
      path: AppRoutes.sellerStore,
      builder: (context, state) =>
          SellerStorefrontScreen(sellerId: _param(state, 'sellerId')),
    ),
  ];
}

class SellerNavigation {
  const SellerNavigation._();

  static void toSellerStore(BuildContext context, String sellerId) {
    context.pushNamed(
      AppRoutes.nSellerStore,
      pathParameters: {'sellerId': sellerId},
    );
  }
}

String _param(GoRouterState state, String key) =>
    Uri.decodeComponent(state.pathParameters[key] ?? '');
