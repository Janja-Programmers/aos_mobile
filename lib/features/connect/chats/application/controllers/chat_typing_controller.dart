import 'dart:async';

import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/connect/chats/application/providers/chat_providers.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_identity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final chatTypingControllerProvider =
    StateNotifierProvider<ChatTypingController, Map<String, bool>>(
      ChatTypingController.new,
    );

class ChatTypingController extends StateNotifier<Map<String, bool>> {
  final Ref ref;

  ChatTypingController(this.ref) : super({}) {
    _listenRealtime();
  }

  final Map<String, Timer> _timers = {};
  StreamSubscription<Object?>? _typingSub;

  // -----------------------------
  // Realtime listener (UPDATED)
  // -----------------------------
  void _listenRealtime() {
    final realtime = ref.read(chatRealtimeServiceProvider);

    _typingSub = realtime.typing.listen((payload) {
      final data = asJsonMap(payload);
      final conversationId = asNullableString(data['conversation_id']);

      // 🔥 ignore invalid payloads
      if (conversationId == null) return;

      // 🔥 ignore own typing (IMPORTANT)
      final fromUser = normalizeCanonicalUserId(
        asNullableString(data['from']),
      );
      final currentUser = normalizeCanonicalUserId(
        ref.read(currentCanonicalAccountIdProvider),
      );
      if (fromUser.isNotEmpty && fromUser == currentUser) return;

      final isTyping = asBool(data['is_typing']);

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
    return state[conversationId] ?? false;
  }

  // -----------------------------
  // Cleanup (IMPORTANT)
  // -----------------------------
  @override
  void dispose() {
    unawaited(_typingSub?.cancel());

    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();

    super.dispose();
  }
}
