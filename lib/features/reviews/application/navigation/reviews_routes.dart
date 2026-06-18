import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/reviews/presentation/review_create_screen.dart';
import 'package:africaonlinestores/features/reviews/presentation/review_screen.dart';

class ReviewsRoutes {
  const ReviewsRoutes._();

  static List<GoRoute> routes() => [..._publicRoutes];

  static final List<GoRoute> _publicRoutes = [
    GoRoute(
      name: AppRoutes.nReview,
      path: AppRoutes.review,
      builder: (context, state) {
        final adId = state.uri.queryParameters['adId'] ?? '';

        return ReviewScreen(adId: adId);
      },
    ),
    GoRoute(
      name: AppRoutes.nCreateReview,
      path: AppRoutes.createReview,
      builder: (context, state) {
        final adId = state.pathParameters['adId'];

        if (adId == null || adId.isEmpty) {
          return const Scaffold(body: Center(child: Text('Missing adId')));
        }

        return ReviewCreateScreen(adId: adId);
      },
    ),
  ];
}

class ReviewNavigation {
  const ReviewNavigation._();

  static Future<void> toAllReviews(BuildContext context, String adId) async {
    await context.pushNamed<void>(
      AppRoutes.nReview,
      queryParameters: {'adId': adId},
    );
  }

  static Future<bool?> toCreateReview(BuildContext context, String adId) {
    return context.pushNamed<bool>(
      AppRoutes.nCreateReview,
      pathParameters: {'adId': adId},
    );
  }
}
