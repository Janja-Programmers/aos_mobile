import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/media/livekit_service.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/realtime/realtime_provider.dart';

import 'package:africaonlinestores/features/connect/calls/application/managers/call_manager.dart';
// import 'package:africaonlinestores/features/connect/calls/application/services/call_kit_service.dart';
import 'package:africaonlinestores/features/connect/calls/application/services/call_media_service.dart';
import 'package:africaonlinestores/features/connect/calls/application/services/call_signaling_handler.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';

import 'package:africaonlinestores/features/connect/calls/data/call_api.dart';
import 'package:africaonlinestores/features/connect/calls/integrations/socket_call_listener.dart';
import 'package:africaonlinestores/features/connect/calls/repository/call_repository_impl.dart';
import 'package:africaonlinestores/features/connect/calls/utils/call_timer.dart';

// ================= API =================
final callApiProvider = Provider<CallApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CallApi(apiClient);
});

// ================= REPOSITORY =================
final callRepositoryProvider = Provider<CallRepository>((ref) {
  final api = ref.watch(callApiProvider);
  return CallRepositoryImpl(api);
});

// ================= CORE =================
final liveKitCoreProvider = Provider<LiveKitService>((ref) {
  return LiveKitService();
});

// ================= MEDIA =================
final callMediaServiceProvider = Provider<CallMediaService>((ref) {
  final liveKit = ref.watch(liveKitCoreProvider);
  return CallMediaService(liveKit);
});

// ================= UTIL =================
final callTimerProvider = Provider<CallTimer>((ref) {
  return CallTimer();
});

// ================= CALL MANAGER =================
final callManagerProvider = StateNotifierProvider<CallManager, CallState>((
  ref,
) {
  final repository = ref.watch(callRepositoryProvider);
  final mediaService = ref.watch(callMediaServiceProvider);
  final callTimer = ref.watch(callTimerProvider);

  return CallManager(
    repository: repository,
    mediaService: mediaService,
    callTimer: callTimer,
  );
});

// ================= SIGNALING =================
final callSignalingHandlerProvider = Provider<CallSignalingHandler>((ref) {
  final manager = ref.read(callManagerProvider.notifier);

  return CallSignalingHandler(callManager: manager);
});

// ================= SOCKET LISTENER =================
final socketCallListenerProvider = Provider<SocketCallListener>((ref) {
  final realtime = ref.watch(realtimeServiceProvider);
  final handler = ref.watch(callSignalingHandlerProvider);
  // final callKit = ref.watch(callKitServiceProvider);

  final listener = SocketCallListener(
    eventStream: realtime.events,
    signalingHandler: handler,
    // callKitService: callKit,
  );

  listener.attach();

  ref.onDispose(listener.dispose);

  return listener;
});

// // ================= CALLKIT =================
// final callKitServiceProvider = Provider<CallKitService>((ref) {
//   final service = CallKitService(ref);

//   service.init();

//   ref.onDispose(service.dispose);

//   return service;
// });
