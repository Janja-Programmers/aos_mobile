import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/chats/controllers/chat_providers.dart';

final chatTypingControllerProvider =
    StateNotifierProvider<ChatTypingController, Map<String, bool>>(
      (ref) => ChatTypingController(ref),
    );

class ChatTypingController extends StateNotifier<Map<String, bool>> {
  final Ref ref;

  ChatTypingController(this.ref) : super({}) {
    _currentUser = ref.read(currentUserProvider) ?? "";
    _listenRealtime();
  }

  late final String _currentUser;

  final Map<String, Timer> _timers = {};
  StreamSubscription? _typingSub;

  // -----------------------------
  // Realtime listener (UPDATED)
  // -----------------------------
  void _listenRealtime() {
    final realtime = ref.read(chatRealtimeServiceProvider);

    _typingSub = realtime.typing.listen((data) {
      final conversationId = data['conversation_id'];

      // 🔥 ignore invalid payloads
      if (conversationId == null) return;

      // 🔥 ignore own typing (IMPORTANT)
      final fromUser = data['from'];
      if (fromUser == _currentUser) return;

      final isTyping = _parseTyping(data['is_typing']);

      _setTyping(conversationId, isTyping);
    });
  }

  // -----------------------------
  // Normalize typing value
  // -----------------------------
  bool _parseTyping(dynamic value) {
    if (value == true) return true;
    if (value == 1) return true;
    return false;
  }

  // -----------------------------
  // Set typing with auto-timeout
  // -----------------------------
  void _setTyping(String conversationId, bool isTyping) {
    // cancel previous timer
    _timers[conversationId]?.cancel();

    if (isTyping) {
      state = {...state, conversationId: true};

      // 🔥 auto reset (failsafe)
      _timers[conversationId] = Timer(const Duration(seconds: 3), () {
        state = {...state, conversationId: false};
        _timers.remove(conversationId);
      });
    } else {
      state = {...state, conversationId: false};
      _timers.remove(conversationId);
    }
  }

  // -----------------------------
  // Public helper
  // -----------------------------
  bool isTyping(String conversationId) {
    return state[conversationId] == true;
  }

  // -----------------------------
  // Cleanup (IMPORTANT)
  // -----------------------------
  @override
  void dispose() {
    _typingSub?.cancel();

    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();

    super.dispose();
  }
}
