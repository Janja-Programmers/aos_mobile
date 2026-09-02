import 'dart:async';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/screens/post_short_details_screen.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/screens/post_short_media_picker_screen.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/screens/short_detail_screen.dart';
import 'package:africaonlinestores/features/shorts/music/domain/short_sound.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/enums/selected_media_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PostShortDetailsArgs {
  final String sessionId;
  final List<SelectedMedia> media;
  final ShortSound selectedSound;

  PostShortDetailsArgs({
    required this.sessionId,
    required this.media,
    required this.selectedSound,
  });
}

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

final _shortDetailByIdProvider = FutureProvider.family<Short, String>((
  ref,
  shortId,
) async {
  final result = await ref
      .read(shortsManagementApiProvider)
      .getShort(shortId: shortId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (short) => short,
  );
});

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

          if (args != null) {
            return ShortDetailScreen(
              initialShorts: args.initialShorts,
              initialIndex: args.initialIndex,
              initialNextCursor: args.initialNextCursor,
              initialHasMore: args.initialHasMore,
            );
          }

          final shortId =
              state.uri.queryParameters['short_id'] ??
              state.uri.queryParameters['shortId'] ??
              state.uri.queryParameters['short'];

          if (shortId != null && shortId.trim().isNotEmpty) {
            return _ShortDetailByIdScreen(shortId: shortId.trim());
          }

          return Scaffold(
            appBar: AppBar(leading: const BackButton()),
            body: const Center(child: Text('Missing short detail data')),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        name: AppRoutes.nPostShort,
        path: AppRoutes.postShort,
        builder: (context, state) {
          final initialSound = state.extra as ShortSound?;
          return PostShortMediaPickerScreen(initialSound: initialSound);
        },
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
              body: const Center(child: Text('Missing post data')),
            );
          }

          return PostShortDetailsScreen(
            sessionId: args.sessionId,
            media: args.media,
            selectedSound: args.selectedSound,
          );
        },
      ),
    ];
  }
}

class _ShortDetailByIdScreen extends ConsumerWidget {
  final String shortId;

  const _ShortDetailByIdScreen({required this.shortId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortAsync = ref.watch(_shortDetailByIdProvider(shortId));

    return shortAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load short.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (short) => ShortDetailScreen(
        initialShorts: [short],
        initialIndex: 0,
        initialNextCursor: null,
        initialHasMore: false,
      ),
    );
  }
}

class ShortsNavigation {
  const ShortsNavigation._();

  static void toShortDetail(
    BuildContext context, {
    required List<Short> initialShorts,
    required int initialIndex,
    required String? initialNextCursor,
    required bool initialHasMore,
  }) {
    unawaited(
      context.pushNamed<void>(
        AppRoutes.nShortDetail,
        extra: ShortDetailArgs(
          initialShorts: initialShorts,
          initialIndex: initialIndex,
          initialNextCursor: initialNextCursor,
          initialHasMore: initialHasMore,
        ),
      ),
    );
  }

  static void toShortDetailById(
    BuildContext context, {
    required String shortId,
  }) {
    unawaited(
      context.pushNamed<void>(
        AppRoutes.nShortDetail,
        queryParameters: <String, String>{'short_id': shortId},
      ),
    );
  }

  static Future<void> toPostShort(
    BuildContext context, {
    ShortSound? initialSound,
  }) async {
    await context.pushNamed<void>(AppRoutes.nPostShort, extra: initialSound);
  }

  static void toPostShortDetails(
    BuildContext context, {
    required String sessionId,
    required List<SelectedMedia> media,
    required ShortSound selectedSound,
  }) {
    unawaited(
      context.pushNamed<void>(
        AppRoutes.nPostShortDetails,
        extra: PostShortDetailsArgs(
          sessionId: sessionId,
          media: media,
          selectedSound: selectedSound,
        ),
      ),
    );
  }
}
