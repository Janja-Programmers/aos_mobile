import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:dio/dio.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/config/app_config.dart';

// ───────────── DATA LAYER ─────────────
import 'package:africaonlinestores/features/shorts/data/datasources/api/shorts_feed_api.dart';
import 'package:africaonlinestores/features/shorts/data/datasources/api/shorts_tracking_api.dart.dart';
import 'package:africaonlinestores/features/shorts/data/datasources/api/shorts_management_api.dart';
import 'package:africaonlinestores/features/shorts/data/datasources/api/shorts_upload_api.dart';
import 'package:africaonlinestores/features/shorts/data/datasources/api/shorts_engagement_api.dart';
import 'package:africaonlinestores/features/shorts/data/datasources/api/shorts_comments_api.dart';
import 'package:africaonlinestores/features/shorts/data/datasources/repository/shorts_repository_impl.dart';

// ───────────── DOMAIN ─────────────
import 'package:africaonlinestores/features/shorts/domain/repository/shorts_repository.dart';

// ───────────── APPLICATION ─────────────

// state
import 'package:africaonlinestores/features/shorts/application/state/feed_controller.dart';
import 'package:africaonlinestores/features/shorts/application/state/feed_state.dart';

// metrics
import 'package:africaonlinestores/features/shorts/application/metrics/metrics_notifier.dart';
import 'package:africaonlinestores/features/shorts/application/metrics/metrics_state.dart';

// coordinator
import 'package:africaonlinestores/features/shorts/application/coordinator/feed_coordinator.dart';

// playback
import 'package:africaonlinestores/features/shorts/application/playback/controller_pool.dart';
import 'package:africaonlinestores/features/shorts/application/playback/playback_orchestrator.dart';

// tracking
import 'package:africaonlinestores/features/shorts/application/tracking/tracking_service.dart';

// upload
import 'package:africaonlinestores/features/shorts/application/upload/upload_orchestrator.dart';
import 'package:africaonlinestores/features/shorts/application/upload/processing_watcher.dart';
import 'package:africaonlinestores/features/shorts/application/upload/upload_state.dart';

// ─────────────────────────────────────────────
// API CLIENT (reuse existing)
// ─────────────────────────────────────────────

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: AppConfig.normalizedBaseUrl, ref: ref);
});

// ─────────────────────────────────────────────
// DATASOURCES
// ─────────────────────────────────────────────

final shortsFeedApiProvider = Provider<ShortsFeedApi>((ref) {
  return ShortsFeedApi(ref.read(apiClientProvider));
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

final shortsTrackingApiProvider = Provider<ShortsTrackingApi>((ref) {
  return ShortsTrackingApi(ref.read(apiClientProvider));
});

// ─────────────────────────────────────────────
// REPOSITORY
// ─────────────────────────────────────────────

final shortsRepositoryProvider = Provider<ShortsRepository>((ref) {
  return ShortsRepositoryImpl(
    feedApi: ref.read(shortsFeedApiProvider),
    managementApi: ref.read(shortsManagementApiProvider),
    uploadApi: ref.read(shortsUploadApiProvider),
    engagementApi: ref.read(shortsEngagementApiProvider),
    commentsApi: ref.read(shortsCommentsApiProvider),
    trackingApi: ref.read(shortsTrackingApiProvider),
  );
});

// ─────────────────────────────────────────────
// METRICS
// ─────────────────────────────────────────────

final metricsNotifierProvider =
    StateNotifierProvider<MetricsNotifier, MetricsState>(
      (ref) => MetricsNotifier(),
    );

// ─────────────────────────────────────────────
// FEED STATE
// ─────────────────────────────────────────────

final feedControllerProvider = StateNotifierProvider<FeedController, FeedState>(
  (ref) {
    return FeedController(
      repository: ref.read(shortsRepositoryProvider),
      metricsNotifier: ref.read(metricsNotifierProvider.notifier),
    );
  },
);

// ─────────────────────────────────────────────
// PLAYBACK SYSTEM
// ─────────────────────────────────────────────

final controllerPoolProvider = Provider<ControllerPool>((ref) {
  final pool = ControllerPool();

  ref.onDispose(() {
    pool.disposeAll();
  });

  return pool;
});

final playbackOrchestratorProvider = Provider<PlaybackOrchestrator>((ref) {
  return PlaybackOrchestrator(ref.read(controllerPoolProvider));
});

// ─────────────────────────────────────────────
// COORDINATOR (REQUIRES PAGE CONTROLLER)
// ─────────────────────────────────────────────

final feedCoordinatorProvider =
    Provider.family<FeedCoordinator, PageController>((ref, pageController) {
      final controller = ref.read(feedControllerProvider);

      final coordinator = FeedCoordinator(
        pageController: pageController,
        totalCount: controller.items.length,
      );

      ref.onDispose(coordinator.dispose);

      return coordinator;
    });

// ─────────────────────────────────────────────
// TRACKING
// ─────────────────────────────────────────────

final trackingServiceProvider = Provider<TrackingService>((ref) {
  final service = TrackingService(ref.read(shortsTrackingApiProvider));

  service.start();

  ref.onDispose(service.dispose);

  return service;
});

// ─────────────────────────────────────────────
// UPLOAD
// ─────────────────────────────────────────────

final processingWatcherProvider = Provider<ProcessingWatcher>((ref) {
  return ProcessingWatcher(ref.read(shortsRepositoryProvider));
});

final uploadOrchestratorProvider =
    StateNotifierProvider<UploadOrchestrator, UploadState>((ref) {
      return UploadOrchestrator(
        repository: ref.read(shortsRepositoryProvider),
        dio: Dio(),
        watcher: ref.read(processingWatcherProvider),
      );
    });
