import 'dart:async';

import 'package:africaonlinestores/core/media/data/media_upload_api_provider.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/live/application/providers/live_providers.dart';
import 'package:africaonlinestores/features/shorts/analytics/data/shorts_analytics_api.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/controllers/post_short_controller.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/controllers/short_publishing_coordinator.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/state/short_state.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/state/upload_state.dart';
import 'package:africaonlinestores/features/shorts/create_short/data/pending_short_publication_repository.dart';
import 'package:africaonlinestores/features/shorts/create_short/data/short_draft_repository.dart';
import 'package:africaonlinestores/features/shorts/create_short/data/short_local_media_saver.dart';
// Controllers
import 'package:africaonlinestores/features/shorts/feeds/application/controllers/comment_controller.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/controllers/replies_controller.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/controllers/short_detail_controller.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/controllers/short_grid_controller.dart';
// State
import 'package:africaonlinestores/features/shorts/feeds/application/state/comment_state.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/replies_state.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/short_detail_state.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/short_grid_state.dart';
import 'package:africaonlinestores/features/shorts/feeds/repository/short_feed_repository.dart';
import 'package:africaonlinestores/features/shorts/music/data/shorts_sounds_api.dart';
import 'package:africaonlinestores/features/shorts/shared/application/controllers/short_controller.dart';
// APIs
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_comments_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_engagement_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_feed_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_library_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_management_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_report_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_share_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_tracking_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_upload_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

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

final shortsShareApiProvider = Provider<ShortsShareApi>((ref) {
  return ShortsShareApi(ref.read(apiClientProvider));
});

final shortsLibraryApiProvider = Provider<ShortsLibraryApi>((ref) {
  return ShortsLibraryApi(ref.read(apiClientProvider));
});

final shortsReportApiProvider = Provider<ShortsReportApi>((ref) {
  return ShortsReportApi(ref.read(apiClientProvider));
});

final shortsAnalyticsApiProvider = Provider<ShortsAnalyticsApi>((ref) {
  return ShortsAnalyticsApi(ref.read(apiClientProvider));
});

final shortsSoundsApiProvider = Provider<ShortsSoundsApi>((ref) {
  return ShortsSoundsApi(ref.read(apiClientProvider));
});

final shortLocalMediaSaverProvider = Provider<ShortLocalMediaSaver>((ref) {
  return const GalShortLocalMediaSaver();
});

final shortDraftRepositoryProvider = Provider<ShortDraftRepository>((ref) {
  return const LocalShortDraftRepository();
});

final pendingShortPublicationRepositoryProvider =
    Provider<PendingShortPublicationRepository>((ref) {
      return const PendingShortPublicationRepository();
    });

final shortPublishingCoordinatorProvider = Provider<ShortPublishingCoordinator>(
  (ref) {
    return ShortPublishingCoordinator(
      uploadApi: ref.read(shortsUploadApiProvider),
      managementApi: ref.read(shortsManagementApiProvider),
      repository: ref.read(pendingShortPublicationRepositoryProvider),
      draftRepository: ref.read(shortDraftRepositoryProvider),
      onReady: (_) {
        unawaited(ref.read(shortsControllerProvider.notifier).loadInitial());
      },
    );
  },
);

// ─────────────────────────────────────────────
// CONTROLLERS (THE BRAIN)
// ─────────────────────────────────────────────

// final activeUploadMediaProvider = StateProvider<List<SelectedMedia>>(
//   (ref) => [],
// );

final activeShortIndexProvider = StateProvider<int>((ref) => 0);

final activeShortUploadSessionProvider = StateProvider<String?>((ref) => null);

final shortsRepositoryProvider = Provider<ShortsRepository>((ref) {
  return ShortsRepository(
    ref.read(shortsFeedApiProvider),
    ref.read(liveApiProvider),
  );
});

final shortsControllerProvider =
    StateNotifierProvider<ShortsController, ShortsState>((ref) {
      return ShortsController(
        ref.read(shortsRepositoryProvider),
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
      final auth = ref.read(authControllerProvider);
      final ownerId = auth is AuthAuthenticated
          ? (auth.user.accountId.isNotEmpty
                ? auth.user.accountId
                : auth.user.email)
          : '';
      return PostShortController(
        uploadApi: ref.read(shortsUploadApiProvider),
        managementApi: ref.read(shortsManagementApiProvider),
        mediaUploadApi: ref.read(mediaUploadApiProvider),
        localMediaSaver: ref.read(shortLocalMediaSaverProvider),
        publishingCoordinator: ref.read(shortPublishingCoordinatorProvider),
        sessionId: sessionId,
        ownerId: ownerId,
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
        repository: ref.read(shortsRepositoryProvider),
        engagementApi: ref.read(shortsEngagementApiProvider),
        trackingApi: ref.read(shortsTrackingApiProvider),
        shareApi: ref.read(shortsShareApiProvider),
        libraryApi: ref.read(shortsLibraryApiProvider),
        reportApi: ref.read(shortsReportApiProvider),
        apiClient: ref.read(apiClientProvider),
      );
    });

final repliesControllerProvider =
    StateNotifierProvider.family<RepliesController, RepliesState, String>((
      ref,
      rootCommentId,
    ) {
      return RepliesController(
        ref.read(shortsCommentsApiProvider),
        rootCommentId,
      );
    });
