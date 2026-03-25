import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/chats/controllers/chat_providers.dart';

class ChatPresenceState {
  final bool isOnline;
  final DateTime? lastSeen;

  ChatPresenceState({required this.isOnline, this.lastSeen});
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
  }

  void _listenRealtime() {
    final realtime = ref.read(chatRealtimeServiceProvider);

    realtime.onPresence((data) {
      final user = data['user'];

      state = {
        ...state,
        user: ChatPresenceState(
          isOnline: data['is_online'],
          lastSeen: data['last_seen'] != null
              ? DateTime.parse(data['last_seen'])
              : null,
        ),
      };
    });
  }
}
