import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';

import 'package:africaonlinestores/features/shorts/shared/domain/selected_media_type.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/screens/shorts_screen.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/screens/post_short_details_screen.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/screens/post_short_media_picker_screen.dart';

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

class ShortsRoutes {
  const ShortsRoutes._();

  static List<GoRoute> routes() => [..._publicRoutes];

  static final List<GoRoute> _publicRoutes = [
    // ───────── SHORTS FEED ─────────
    GoRoute(
      name: AppRoutes.nShorts,
      path: AppRoutes.shorts,
      builder: (context, state) {
        return const ShortsScreen();
      },
    ),

    // ───────── MEDIA PICKER ─────────
    GoRoute(
      name: AppRoutes.nPostShort,
      path: AppRoutes.postShort,
      builder: (context, state) => const PostShortMediaPickerScreen(),
    ),

    // ───────── DETAILS SCREEN ─────────
    GoRoute(
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

/// ─────────────────────────────────────────
/// NAVIGATION HELPERS
/// ─────────────────────────────────────────

class ShortsNavigation {
  const ShortsNavigation._();

  // ───────── OPEN FEED ─────────

  static void toShorts(BuildContext context, {int initialIndex = 0}) {
    context.pushNamed(AppRoutes.nShorts, extra: initialIndex);
  }

  // ───────── OPEN MEDIA PICKER ─────────

  static Future<void> toPostShort(BuildContext context) {
    return context.pushNamed(AppRoutes.nPostShort);
  }

  // ───────── OPEN DETAILS ─────────

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
