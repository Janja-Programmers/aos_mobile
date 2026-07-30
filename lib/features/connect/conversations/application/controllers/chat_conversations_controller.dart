import 'dart:async';

import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/connect/chats/application/providers/chat_providers.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_conversation.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/repository/chat_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class ConversationsController
    extends StateNotifier<AsyncValue<List<ChatConversation>>> {
  final Ref ref;

  String _currentUser = '';
  String? _activeSid;
  bool _isBootstrapping = false;
  int _loadSerial = 0;

  StreamSubscription<Object?>? _messageSub;
  StreamSubscription<Object?>? _messageEditedSub;
  StreamSubscription<Object?>? _messagesDeletedSub;

  ConversationsController(this.ref) : super(const AsyncLoading()) {
    ref.listen<AuthState>(
      authControllerProvider,
      _handleAuthChanged,
      fireImmediately: true,
    );
  }

  // -----------------------------
  // Auth-aware bootstrap
  // -----------------------------
  void _handleAuthChanged(AuthState? previous, AuthState next) {
    if (next is AuthAuthenticated) {
      final sid = next.sid.trim();
      final user = _normalizeUser(next.user.email);

      if (_activeSid == sid && _currentUser == user && state.hasValue) {
        return;
      }

      _activeSid = sid;
      _currentUser = user.isNotEmpty
          ? user
          : _normalizeUser(ref.read(currentUserProvider));

      unawaited(_bootstrapForAuthenticatedUser());
      return;
    }

    if (next is AuthGuest) {
      _activeSid = null;
      _currentUser = '';
      _loadSerial++;
      unawaited(_cancelRealtimeSubscriptions());
      state = const AsyncData([]);
      return;
    }

    if (next is AuthLoading && !state.hasValue) {
      state = const AsyncLoading();
    }
  }

  Future<void> _bootstrapForAuthenticatedUser() async {
    if (_isBootstrapping) return;

    _isBootstrapping = true;

    try {
      if (!state.hasValue) {
        state = const AsyncLoading();
      }

      await load();
      await _subscribeToRealtime();
    } finally {
      _isBootstrapping = false;
    }
  }

  // -----------------------------
  // Load conversations
  // -----------------------------
  Future<void> load() async {
    final auth = ref.read(authControllerProvider);

    if (auth is! AuthAuthenticated) {
      state = const AsyncData([]);
      return;
    }

    final serial = ++_loadSerial;
    final repo = ref.read(chatRepositoryProvider);
    final res = await repo.getConversations();

    if (!mounted || serial != _loadSerial) return;

    if (res.isLeft) {
      final failure = res.leftOrNull!;
      appLogger.w('[ConversationsController] load failed: ${failure.message}');
      state = AsyncError(failure, StackTrace.current);
      return;
    }

    final conversations = List<ChatConversation>.from(res.rightOrNull ?? []);

    conversations.sort((a, b) {
      final aTime = a.lastMessageAt;
      final bTime = b.lastMessageAt;

      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;

      return bTime.compareTo(aTime);
    });

    state = AsyncData(conversations);
  }

  Future<void> refresh() async {
    final auth = ref.read(authControllerProvider);

    if (auth is! AuthAuthenticated) {
      state = const AsyncData([]);
      return;
    }

    state = const AsyncLoading();
    await load();
  }

  // -----------------------------
  // Delete conversation
  // -----------------------------
  Future<bool> deleteConversation(String conversationId) async {
    final cleanId = conversationId.trim();

    if (cleanId.isEmpty) {
      return false;
    }

    final repo = ref.read(chatRepositoryProvider);
    final previousState = state;

    state = state.whenData((conversations) {
      return conversations.where((c) => c.id != cleanId).toList();
    });

    final res = await repo.deleteConversation(cleanId);

    if (!mounted) return false;

    if (res.isLeft) {
      state = previousState;

      appLogger.w('[ChatController] Failed to delete: ${res.leftOrNull}');
      return false;
    }

    appLogger.i('[ChatController] Conversation deleted successfully');
    return true;
  }

  // -----------------------------
  // Local read update
  // -----------------------------
  void markConversationAsReadLocally(String conversationId) {
    state = state.whenData((conversations) {
      return conversations.map((conversation) {
        if (conversation.id != conversationId) return conversation;

        return conversation.copyWith(unreadCount: 0);
      }).toList();
    });
  }

  // -----------------------------
  // Public sync from message screen
  // -----------------------------
  void syncConversationWithMessage({
    required String conversationId,
    required ChatMessage message,
    String? fallbackUser,
    String? fallbackDisplayName,
    String? fallbackAvatar,
    bool incrementUnread = false,
  }) {
    final preview = _messagePreview(message);

    _upsertConversationPreview(
      conversationId: conversationId,
      lastMessage: preview,
      lastMessageAt: message.createdAt,
      incrementUnread: incrementUnread,
      fallbackUser: fallbackUser,
      fallbackDisplayName: fallbackDisplayName,
      fallbackAvatar: fallbackAvatar,
    );
  }

  // -----------------------------
  // Realtime subscription
  // -----------------------------
  Future<void> _subscribeToRealtime() async {
    final realtime = ref.read(chatRealtimeServiceProvider);

    await _cancelRealtimeSubscriptions();

    _messageSub = realtime.messages.listen((Object? data) {
      final payload = asJsonMap(data);
      final conversationId = payload['conversation_id']?.toString();
      final rawMessage = payload['message'];

      if (conversationId == null || conversationId.trim().isEmpty) return;
      if (rawMessage is! Map) return;

      final message = ChatMessage.fromJson(asJsonMap(rawMessage));

      final sender = _normalizeUser(message.sender);
      final shouldIncrement = sender.isNotEmpty && sender != _currentUser;

      syncConversationWithMessage(
        conversationId: conversationId,
        message: message,
        incrementUnread: shouldIncrement,
        fallbackUser: shouldIncrement ? message.sender : null,
        fallbackDisplayName: message.senderDisplayName,
        fallbackAvatar: message.senderAvatar,
      );
    });

    _messageEditedSub = realtime.messageEdited.listen((Object? data) {
      final payload = asJsonMap(data);
      final conversationId = payload['conversation_id']?.toString();
      final rawMessage = payload['message'];

      if (conversationId == null || conversationId.trim().isEmpty) return;
      if (rawMessage is! Map) return;

      final message = ChatMessage.fromJson(asJsonMap(rawMessage));

      syncConversationWithMessage(
        conversationId: conversationId,
        message: message,
      );
    });

    _messagesDeletedSub = realtime.messagesDeleted.listen((Object? _) {
      unawaited(load());
    });
  }

  Future<void> _cancelRealtimeSubscriptions() async {
    await _messageSub?.cancel();
    await _messageEditedSub?.cancel();
    await _messagesDeletedSub?.cancel();

    _messageSub = null;
    _messageEditedSub = null;
    _messagesDeletedSub = null;
  }

  // -----------------------------
  // Internal preview upsert
  // -----------------------------
  void _upsertConversationPreview({
    required String conversationId,
    required String lastMessage,
    required DateTime lastMessageAt,
    bool incrementUnread = false,
    String? fallbackUser,
    String? fallbackDisplayName,
    String? fallbackAvatar,
  }) {
    final List<ChatConversation> current = state.maybeWhen(
      data: List<ChatConversation>.from,
      orElse: () => <ChatConversation>[],
    );

    final index = current.indexWhere((c) => c.id == conversationId);

    if (index != -1) {
      final existing = current[index];

      final updatedConversation = existing.copyWith(
        lastMessage: lastMessage,
        lastMessageAt: lastMessageAt,
        unreadCount: incrementUnread
            ? existing.unreadCount + 1
            : existing.unreadCount,
      );

      final updatedList = List<ChatConversation>.from(current)
        ..removeAt(index)
        ..insert(0, updatedConversation);

      state = AsyncData(updatedList);
      return;
    }

    final newConversation = ChatConversation(
      id: conversationId,
      user: fallbackUser ?? '',
      displayName: _safeText(fallbackDisplayName) ?? 'New Chat',
      avatar: _safeText(fallbackAvatar),
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt,
      unreadCount: incrementUnread ? 1 : 0,
    );

    state = AsyncData(<ChatConversation>[newConversation, ...current]);
  }

  String _messagePreview(ChatMessage message) {
    final text = message.content?.trim();

    if (text != null && text.isNotEmpty) {
      return text;
    }

    if (message.hasAd || message.hasAdPreview) {
      return 'Ad preview';
    }

    if (message.attachments.isNotEmpty || message.hasAttachments) {
      final firstType = message.attachments.isNotEmpty
          ? message.attachments.first.type.trim().toLowerCase()
          : '';

      if (firstType.contains('image')) return 'Photo';
      if (firstType.contains('video')) return 'Video';
      if (firstType.contains('audio') || firstType.contains('voice')) {
        return 'Voice note';
      }

      return 'Attachment';
    }

    if (message.isSystemMessage) {
      return 'System message';
    }

    return 'Message';
  }

  String _normalizeUser(String? value) {
    return value?.trim().toLowerCase() ?? '';
  }

  String? _safeText(String? value) {
    final clean = value?.trim();
    if (clean == null || clean.isEmpty || clean.toLowerCase() == 'null') {
      return null;
    }

    return clean;
  }

  // -----------------------------
  // Dispose
  // -----------------------------
  @override
  void dispose() {
    unawaited(_cancelRealtimeSubscriptions());
    super.dispose();
  }
}
