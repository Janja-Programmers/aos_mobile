import 'dart:async';

import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/connect/chats/application/providers/chat_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class ChatPresenceState {
  final bool isOnline;
  final DateTime? lastSeen;

  ChatPresenceState({required this.isOnline, this.lastSeen});

  ChatPresenceState copyWith({bool? isOnline, DateTime? lastSeen}) {
    return ChatPresenceState(
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

final chatPresenceControllerProvider =
    StateNotifierProvider<
      ChatPresenceController,
      Map<String, ChatPresenceState>
    >(ChatPresenceController.new);

class ChatPresenceController
    extends StateNotifier<Map<String, ChatPresenceState>> {
  final Ref ref;

  ChatPresenceController(this.ref) : super({}) {
    _listenRealtime();
    _startCleanupTimer();
  }

  StreamSubscription<Object?>? _presenceSub;

  // fallback cleanup timer (handles silent disconnects)
  Timer? _cleanupTimer;

  // -----------------------------
  // Realtime listener (UPDATED)
  // -----------------------------
  void _listenRealtime() {
    final realtime = ref.read(chatRealtimeServiceProvider);

    _presenceSub = realtime.presence.listen((payload) {
      final data = asJsonMap(payload);
      final user = asNullableString(data['user']);
      if (user == null) return;

      final isOnline = asBool(data['is_online']);
      final lastSeen = _parseDate(data['last_seen']);

      state = {
        ...state,
        user: ChatPresenceState(isOnline: isOnline, lastSeen: lastSeen),
      };
    });
  }

  // -----------------------------
  // Helpers
  // -----------------------------
  DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  // -----------------------------
  // Smart "isOnline" (with fallback)
  // -----------------------------
  bool isUserOnline(String user) {
    final presence = state[user];
    if (presence == null) return false;

    // realtime says online
    if (presence.isOnline) return true;

    // fallback: recent lastSeen (grace window)
    if (presence.lastSeen != null) {
      final diff = DateTime.now().difference(presence.lastSeen!);
      return diff.inSeconds < 30;
    }

    return false;
  }

  // -----------------------------
  // Cleanup stale "online" states
  // -----------------------------
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      final now = DateTime.now();

      final updated = <String, ChatPresenceState>{};

      for (final entry in state.entries) {
        final user = entry.key;
        final presence = entry.value;

        if (presence.isOnline && presence.lastSeen != null) {
          final diff = now.difference(presence.lastSeen!);

          // 🔥 force offline if stale
          if (diff.inSeconds > 30) {
            updated[user] = presence.copyWith(isOnline: false);
            continue;
          }
        }

        updated[user] = presence;
      }

      state = updated;
    });
  }

  // -----------------------------
  // Public getter
  // -----------------------------
  ChatPresenceState? getPresence(String user) {
    return state[user];
  }

  // -----------------------------
  // Dispose (IMPORTANT)
  // -----------------------------
  @override
  void dispose() {
    unawaited(_presenceSub?.cancel());
    _cleanupTimer?.cancel();
    super.dispose();
  }
}
