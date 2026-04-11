import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/realtime/realtime_provider.dart';

import 'package:africaonlinestores/features/calls/application/managers/call_manager.dart';
import 'package:africaonlinestores/features/calls/application/services/call_signaling_handler.dart';
import 'package:africaonlinestores/features/calls/application/services/livekit_service.dart';
import 'package:africaonlinestores/features/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/calls/data/call_api.dart';
import 'package:africaonlinestores/features/calls/integrations/socket_call_listener.dart';
import 'package:africaonlinestores/features/calls/repository/call_repository_impl.dart';
import 'package:africaonlinestores/features/calls/utils/call_timer.dart';

// 🔥 YOU MUST IMPORT YOUR GLOBAL PROVIDERS
// Example (adjust to your actual paths)

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

// ================= SERVICES =================
final liveKitServiceProvider = Provider<LiveKitService>((ref) {
  return LiveKitService();
});

final callTimerProvider = Provider<CallTimer>((ref) {
  return CallTimer();
});

// ================= CALL MANAGER =================
final callManagerProvider = StateNotifierProvider<CallManager, CallState>((
  ref,
) {
  final repository = ref.watch(callRepositoryProvider);
  final liveKitService = ref.watch(liveKitServiceProvider);
  final callTimer = ref.watch(callTimerProvider);

  return CallManager(
    repository: repository,
    liveKitService: liveKitService,
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

  final listener = SocketCallListener(
    eventStream: realtime.events,
    signalingHandler: handler,
  );

  // 🔥 Attach once
  listener.attach();

  // 🔥 Clean up when provider is disposed
  ref.onDispose(listener.dispose);

  return listener;
});
