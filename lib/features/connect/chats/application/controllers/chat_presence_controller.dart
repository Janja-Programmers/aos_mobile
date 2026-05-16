import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/connect/chats/application/providers/chat_providers.dart';

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
    >((ref) => ChatPresenceController(ref));

class ChatPresenceController
    extends StateNotifier<Map<String, ChatPresenceState>> {
  final Ref ref;

  ChatPresenceController(this.ref) : super({}) {
    _listenRealtime();
    _startCleanupTimer();
  }

  StreamSubscription? _presenceSub;

  // fallback cleanup timer (handles silent disconnects)
  Timer? _cleanupTimer;

  // -----------------------------
  // Realtime listener (UPDATED)
  // -----------------------------
  void _listenRealtime() {
    final realtime = ref.read(chatRealtimeServiceProvider);

    _presenceSub = realtime.presence.listen((data) {
      final user = data['user'];
      if (user == null) return;

      final isOnline = _parseBool(data['is_online']);
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
  bool _parseBool(dynamic value) {
    if (value == true) return true;
    if (value == 1) return true;
    return false;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value);
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
    _presenceSub?.cancel();
    _cleanupTimer?.cancel();
    super.dispose();
  }
}
