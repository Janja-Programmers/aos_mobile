import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/chats/controllers/chat_providers.dart';
import 'package:africaonlinestores/features/chats/repository/chat_repository_impl.dart';
import 'package:africaonlinestores/features/chats/domain/chat_conversation.dart';

final chatConversationsControllerProvider =
    StateNotifierProvider<
      ChatConversationsController,
      AsyncValue<List<ChatConversation>>
    >((ref) => ChatConversationsController(ref));

class ChatConversationsController
    extends StateNotifier<AsyncValue<List<ChatConversation>>> {
  final Ref ref;

  ChatConversationsController(this.ref) : super(const AsyncLoading()) {
    _init();
  }

  Future<void> _init() async {
    await load();
    _subscribeToRealtime();
  }

  Future<void> load() async {
    final repo = ref.read(chatRepositoryProvider);

    final res = await repo.getConversations();

    if (res.isLeft) {
      state = AsyncError(res.leftOrNull!, StackTrace.current);
    } else {
      state = AsyncData(res.rightOrNull!);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    final repo = ref.read(chatRepositoryProvider);
    final res = await repo.getConversations();

    if (res.isLeft) {
      state = AsyncError(res.leftOrNull!, StackTrace.current);
      return;
    }

    state = AsyncData(res.rightOrNull!);
  }

  void markConversationAsReadLocally(String conversationId) {
    state = state.whenData((conversations) {
      return conversations.map((c) {
        if (c.id == conversationId) {
          return c.copyWith(unreadCount: 0);
        }
        return c;
      }).toList();
    });
  }

  // -----------------------------
  // Realtime subscription
  // -----------------------------
  void _subscribeToRealtime() {
    final realtime = ref.read(chatRealtimeServiceProvider);
    final currentUser = ref.read(currentUserProvider);

    // New messages
    realtime.onNewMessage((data) {
      final convId = data['conversation_id'];
      final message = data['message']['content'] ?? '';
      final sender = data['message']['sender'];

      final shouldIncrement = sender != currentUser;

      _updateConversationPreview(
        conversationId: convId,
        lastMessage: message,
        incrementUnread: shouldIncrement,
      );
    });

    // Typing indicators
    realtime.onTyping((data) {
      // optional: update a Map<String,bool> of typing states if needed
    });

    // Presence updates
    realtime.onPresence((data) {
      // optional: handle presence globally if needed
    });
  }

  // -----------------------------
  // Update conversation preview
  // -----------------------------
  void _updateConversationPreview({
    required String conversationId,
    required String lastMessage,
    bool incrementUnread = false,
  }) {
    final current = state.value ?? [];

    final updated = current.map((c) {
      if (c.id == conversationId) {
        return ChatConversation(
          id: c.id,
          user: c.user,
          displayName: c.displayName,
          avatar: c.avatar,
          lastMessage: lastMessage,
          lastMessageAt: DateTime.now(),
          unreadCount: incrementUnread ? c.unreadCount + 1 : c.unreadCount,
        );
      }
      return c;
    }).toList();

    state = AsyncData(updated);
  }
}
