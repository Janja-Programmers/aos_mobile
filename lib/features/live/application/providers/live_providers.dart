import 'dart:async';

import 'package:africaonlinestores/core/media/application/media_services_provider.dart';
import 'package:africaonlinestores/core/media/livekit_service.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/realtime/realtime_provider.dart';
import 'package:africaonlinestores/features/live/application/controllers/live_cohost_controller.dart';
import 'package:africaonlinestores/features/live/application/managers/live_manager.dart';
import 'package:africaonlinestores/features/live/application/services/live_media_service.dart';
import 'package:africaonlinestores/features/live/application/services/live_realtime_coordinator.dart';
import 'package:africaonlinestores/features/live/application/services/live_sharing_service.dart';
import 'package:africaonlinestores/features/live/application/state/live_state.dart';
import 'package:africaonlinestores/features/live/comments/live_comments_controller.dart';
import 'package:africaonlinestores/features/live/data/live_api.dart';
import 'package:africaonlinestores/features/live/data/live_cohost_api.dart';
import 'package:africaonlinestores/features/live/repository/live_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final liveApiProvider = Provider<LiveApi>((ref) {
  return LiveApi(ref.watch(apiClientProvider));
});

final liveRepositoryProvider = Provider<LiveRepository>((ref) {
  return LiveRepositoryImpl(ref.watch(liveApiProvider));
});

final liveKitCoreProvider = Provider<LiveKitService>((ref) {
  final service = LiveKitService();
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});

final liveMediaServiceProvider = Provider<LiveMediaService>((ref) {
  return LiveMediaService(
    ref.watch(liveKitCoreProvider),
    cameraResources: ref.read(mediaCameraResourceCoordinatorProvider),
  );
});

final liveManagerProvider = StateNotifierProvider<LiveManager, LiveState>((
  ref,
) {
  return LiveManager(
    repository: ref.read(liveRepositoryProvider),
    mediaService: ref.read(liveMediaServiceProvider),
    realtimeService: ref.read(realtimeServiceProvider),
  );
});

final liveCohostControllerProvider =
    StateNotifierProvider<LiveCohostController, LiveCohostState>((ref) {
      return LiveCohostController(
        ref.read(liveCohostApiProvider),
        ref.read(liveManagerProvider.notifier),
      );
    });

final liveSharingServiceProvider = Provider<LiveSharingService>((ref) {
  return LiveSharingService(ref.read(liveRepositoryProvider));
});

final liveRealtimeCoordinatorProvider = Provider<LiveRealtimeCoordinator>((
  ref,
) {
  final coordinator = LiveRealtimeCoordinator(
    realtime: ref.read(realtimeServiceProvider),
    liveManager: ref.read(liveManagerProvider.notifier),
    commentsController: ref.read(liveCommentsControllerProvider.notifier),
    cohostController: ref.read(liveCohostControllerProvider.notifier),
  );
  coordinator.start();
  ref.onDispose(() => unawaited(coordinator.dispose()));
  return coordinator;
});
