import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/chats/controllers/chat_providers.dart';

final chatTypingControllerProvider =
    StateNotifierProvider<ChatTypingController, Map<String, bool>>(
      (ref) => ChatTypingController(ref),
    );

class ChatTypingController extends StateNotifier<Map<String, bool>> {
  final Ref ref;

  ChatTypingController(this.ref) : super({}) {
    _listenRealtime();
  }

  final Map<String, Timer> _timers = {};

  // -----------------------------
  // Realtime listener
  // -----------------------------
  void _listenRealtime() {
    final realtime = ref.read(chatRealtimeServiceProvider);

    realtime.onTyping((data) {
      final conversationId = data['conversation_id'];
      final isTyping = data['is_typing'] == 1;

      _setTyping(conversationId, isTyping);
    });
  }

  // -----------------------------
  // Set typing with auto-timeout
  // -----------------------------
  void _setTyping(String conversationId, bool isTyping) {
    // cancel previous timer
    _timers[conversationId]?.cancel();

    if (isTyping) {
      state = {...state, conversationId: true};

      // 🔥 auto reset after 3 seconds
      _timers[conversationId] = Timer(const Duration(seconds: 3), () {
        state = {...state, conversationId: false};
      });
    } else {
      state = {...state, conversationId: false};
    }
  }

  @override
  void dispose() {
    for (final t in _timers.values) {
      t.cancel();
    }
    super.dispose();
  }
}
