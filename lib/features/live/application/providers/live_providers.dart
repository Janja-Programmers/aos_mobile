import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/realtime/realtime_provider.dart';

// ✅ CORE
import 'package:africaonlinestores/core/media/livekit_service.dart';

// DATA
import 'package:africaonlinestores/features/live/data/live_api.dart';
import 'package:africaonlinestores/features/live/repository/live_repository_impl.dart';

// STATE
import 'package:africaonlinestores/features/live/application/state/live_state.dart';

// SERVICES
import 'package:africaonlinestores/features/live/application/services/live_signaling_handler.dart';
import 'package:africaonlinestores/features/live/application/services/live_media_service.dart';

// MANAGER
import 'package:africaonlinestores/features/live/application/managers/live_manager.dart';

// INTEGRATIONS
import 'package:africaonlinestores/features/live/integrations/socket_live_listener.dart';

// ================= API =================
final liveApiProvider = Provider<LiveApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LiveApi(apiClient);
});

// ================= REPOSITORY =================
final liveRepositoryProvider = Provider<LiveRepository>((ref) {
  final api = ref.watch(liveApiProvider);
  return LiveRepositoryImpl(api);
});

// ================= CORE =================
final liveKitCoreProvider = Provider<LiveKitService>((ref) {
  return LiveKitService();
});

// ================= MEDIA =================
final liveMediaServiceProvider = Provider<LiveMediaService>((ref) {
  final liveKit = ref.watch(liveKitCoreProvider);
  return LiveMediaService(liveKit);
});

// ================= MANAGER =================
final liveManagerProvider = StateNotifierProvider<LiveManager, LiveState>((
  ref,
) {
  return LiveManager(
    repository: ref.read(liveRepositoryProvider),
    mediaService: ref.read(liveMediaServiceProvider),
    realtimeService: ref.read(realtimeServiceProvider),
  );
});

// ================= SIGNALING =================
final liveSignalingHandlerProvider = Provider<LiveSignalingHandler>((ref) {
  final manager = ref.read(liveManagerProvider.notifier);

  return LiveSignalingHandler(liveManager: manager);
});

// ================= SOCKET LISTENER =================
final socketLiveListenerProvider = Provider<SocketLiveListener>((ref) {
  final realtime = ref.watch(realtimeServiceProvider);
  final handler = ref.watch(liveSignalingHandlerProvider);

  final listener = SocketLiveListener(
    eventStream: realtime.events,
    signalingHandler: handler,
  );

  listener.attach();

  ref.onDispose(listener.dispose);

  return listener;
});
