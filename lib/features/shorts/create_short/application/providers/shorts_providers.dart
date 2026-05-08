import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/providers.dart';

// APIs
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_comments_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_engagement_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_feed_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_management_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_upload_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_tracking_api.dart';

// Controllers
import 'package:africaonlinestores/features/shorts/feeds/application/controllers/comment_controller.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/controllers/post_short_controller.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/controllers/short_controller.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/controllers/short_detail_controller.dart';

// State
import 'package:africaonlinestores/features/shorts/feeds/application/state/comment_state.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/state/short_state.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/state/upload_state.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/short_detail_state.dart';

import 'package:africaonlinestores/features/shorts/feeds/application/controllers/short_grid_controller.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/short_grid_state.dart';
import 'package:africaonlinestores/features/shorts/feeds/repository/short_feed_repository.dart';

// ─────────────────────────────────────────────
// API LAYER
// ─────────────────────────────────────────────

final shortsFeedApiProvider = Provider<ShortsFeedApi>((ref) {
  return ShortsFeedApi(ref.read(apiClientProvider));
});

final shortsTrackingApiProvider = Provider<ShortsTrackingApi>((ref) {
  return ShortsTrackingApi(ref.read(apiClientProvider));
});

final shortsManagementApiProvider = Provider<ShortsManagementApi>((ref) {
  return ShortsManagementApi(ref.read(apiClientProvider));
});

final shortsUploadApiProvider = Provider<ShortsUploadApi>((ref) {
  return ShortsUploadApi(ref.read(apiClientProvider));
});

final shortsEngagementApiProvider = Provider<ShortsEngagementApi>((ref) {
  return ShortsEngagementApi(ref.read(apiClientProvider));
});

final shortsCommentsApiProvider = Provider<ShortsCommentsApi>((ref) {
  return ShortsCommentsApi(ref.read(apiClientProvider));
});

// ─────────────────────────────────────────────
// CONTROLLERS (THE BRAIN)
// ─────────────────────────────────────────────

// final activeUploadMediaProvider = StateProvider<List<SelectedMedia>>(
//   (ref) => [],
// );

final activeShortIndexProvider = StateProvider<int>((ref) => 0);

final shortsControllerProvider =
    StateNotifierProvider<ShortsController, ShortsState>((ref) {
      return ShortsController(
        ShortsRepository(ref.read(shortsFeedApiProvider)),
        ref.read(shortsTrackingApiProvider),
        ref.read(shortsEngagementApiProvider),
      );
    });

final shortGridControllerProvider =
    StateNotifierProvider<ShortGridController, ShortGridState>((ref) {
      return ShortGridController(ref.read(shortsFeedApiProvider));
    });

final postShortControllerProvider =
    StateNotifierProvider.family<PostShortController, UploadState, String>((
      ref,
      sessionId,
    ) {
      return PostShortController(
        uploadApi: ref.read(shortsUploadApiProvider),
        managementApi: ref.read(shortsManagementApiProvider),
        sessionId: sessionId,
      );
    });

final commentsControllerProvider =
    StateNotifierProvider<CommentsController, CommentsState>((ref) {
      return CommentsController(ref.read(shortsCommentsApiProvider));
    });

final shortDetailControllerProvider =
    StateNotifierProvider.family<
      ShortDetailController,
      ShortDetailState,
      ShortDetailArgs
    >((ref, args) {
      return ShortDetailController(
        args: args,
        repository: ShortsRepository(ref.read(shortsFeedApiProvider)),
        engagementApi: ref.read(shortsEngagementApiProvider),
      );
    });
