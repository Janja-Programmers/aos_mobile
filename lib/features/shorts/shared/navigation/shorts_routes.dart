import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';

import 'package:africaonlinestores/features/shorts/create_short/presentation/screens/post_short_details_screen.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/screens/post_short_media_picker_screen.dart';

import 'package:africaonlinestores/features/shorts/feeds/presentation/screens/short_detail_screen.dart';

import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/selected_media_type.dart';

/// ─────────────────────────────────────────
/// ARGUMENT MODEL
/// ─────────────────────────────────────────
class PostShortDetailsArgs {
  final String sessionId;
  final List<SelectedMedia> media;

  PostShortDetailsArgs({required this.sessionId, required this.media});
}

/// ─────────────────────────────────────────
/// ROUTES
/// ─────────────────────────────────────────

class ShortDetailArgs {
  final List<Short> initialShorts;
  final int initialIndex;
  final String? initialNextCursor;
  final bool initialHasMore;

  ShortDetailArgs({
    required this.initialShorts,
    required this.initialIndex,
    required this.initialNextCursor,
    required this.initialHasMore,
  });
}

class ShortsRoutes {
  const ShortsRoutes._();

  static List<GoRoute> routes({
    required GlobalKey<NavigatorState> rootNavigatorKey,
  }) {
    return [..._publicRoutes(rootNavigatorKey)];
  }

  static List<GoRoute> _publicRoutes(
    GlobalKey<NavigatorState> rootNavigatorKey,
  ) {
    return [
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.nShortDetail,
        path: AppRoutes.shortDetail,
        builder: (context, state) {
          final args = state.extra as ShortDetailArgs?;

          if (args == null) {
            return Scaffold(
              appBar: AppBar(leading: const BackButton()),
              body: const Center(child: Text('Missing short detail data')),
            );
          }

          return ShortDetailScreen(
            initialShorts: args.initialShorts,
            initialIndex: args.initialIndex,
            initialNextCursor: args.initialNextCursor,
            initialHasMore: args.initialHasMore,
          );
        },
      ),

      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.nPostShort,
        path: AppRoutes.postShort,
        builder: (context, state) => const PostShortMediaPickerScreen(),
      ),

      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.nPostShortDetails,
        path: AppRoutes.postShortDetails,
        builder: (context, state) {
          final args = state.extra as PostShortDetailsArgs?;

          if (args == null) {
            return Scaffold(
              appBar: AppBar(leading: const BackButton()),
              body: const Center(child: Text("Missing post data")),
            );
          }

          return PostShortDetailsScreen(
            sessionId: args.sessionId,
            media: args.media,
          );
        },
      ),
    ];
  }
}

/// ─────────────────────────────────────────
/// NAVIGATION HELPERS
/// ─────────────────────────────────────────
class ShortsNavigation {
  const ShortsNavigation._();

  // ───────── OPEN FEED DETAIL ─────────

  static void toShortDetail(
    BuildContext context, {
    required List<Short> initialShorts,
    required int initialIndex,
    required String? initialNextCursor,
    required bool initialHasMore,
  }) {
    context.pushNamed(
      AppRoutes.nShortDetail,
      extra: ShortDetailArgs(
        initialShorts: initialShorts,
        initialIndex: initialIndex,
        initialNextCursor: initialNextCursor,
        initialHasMore: initialHasMore,
      ),
    );
  }

  // ───────── CREATE SHORTS ROUTES ─────────

  static Future<void> toPostShort(BuildContext context) {
    return context.pushNamed(AppRoutes.nPostShort);
  }

  static void toPostShortDetails(
    BuildContext context, {
    required String sessionId,
    required List<SelectedMedia> media,
  }) {
    context.pushNamed(
      AppRoutes.nPostShortDetails,
      extra: PostShortDetailsArgs(sessionId: sessionId, media: media),
    );
  }
}
