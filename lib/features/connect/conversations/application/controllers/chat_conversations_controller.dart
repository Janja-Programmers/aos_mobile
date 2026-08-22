import 'dart:async';

import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/connect/chats/application/providers/chat_providers.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_conversation.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_identity.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/repository/chat_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class ConversationBulkActionResult {
  const ConversationBulkActionResult({
    required this.succeededIds,
    required this.failedIds,
  });

  final Set<String> succeededIds;
  final Set<String> failedIds;

  bool get isComplete => failedIds.isEmpty;
  int get succeededCount => succeededIds.length;
}

class ConversationsController
    extends StateNotifier<AsyncValue<List<ChatConversation>>> {
  final Ref ref;

  String _currentUser = '';
  String? _activeSid;
  int _bootstrapSerial = 0;
  int _loadSerial = 0;
  int _nextOffset = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  static const int _pageSize = 30;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  StreamSubscription<Object?>? _messageSub;
  StreamSubscription<Object?>? _messageStatusSub;
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
      final user = normalizeCanonicalUserId(next.user.accountId);

      if (_activeSid == sid && _currentUser == user) {
        return;
      }

      _activeSid = sid;
      _currentUser = user.isNotEmpty
          ? user
          : normalizeCanonicalUserId(
              ref.read(currentCanonicalAccountIdProvider),
            );

      // A conversation list belongs to exactly one authenticated account.
      // Clear it before loading the next session so account A is never rendered
      // while account B is becoming active.
      ++_loadSerial;
      _nextOffset = 0;
      _hasMore = true;
      _isLoadingMore = false;
      state = const AsyncLoading();
      unawaited(_cancelRealtimeSubscriptions());

      final bootstrapSerial = ++_bootstrapSerial;
      unawaited(_bootstrapForAuthenticatedUser(bootstrapSerial));
      return;
    }

    if (next is AuthGuest || next is AuthRestorationFailure) {
      _activeSid = null;
      _currentUser = '';
      _loadSerial++;
      _bootstrapSerial++;
      _nextOffset = 0;
      _hasMore = true;
      _isLoadingMore = false;
      unawaited(_cancelRealtimeSubscriptions());
      state = const AsyncData([]);
      return;
    }

    if (next is AuthLoading && !state.hasValue) {
      state = const AsyncLoading();
    }
  }

  Future<void> _bootstrapForAuthenticatedUser(int bootstrapSerial) async {
    if (!state.hasValue) {
      state = const AsyncLoading();
    }

    await load();
    if (!mounted || bootstrapSerial != _bootstrapSerial) return;

    await _subscribeToRealtime();
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
    _nextOffset = 0;
    _hasMore = true;
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
    _nextOffset = conversations.length;
    _hasMore = conversations.length >= _pageSize;

    conversations.sort(_compareConversations);

    state = AsyncData(conversations);
  }

  Future<void> loadMore() async {
    final auth = ref.read(authControllerProvider);
    if (auth is! AuthAuthenticated ||
        _isLoadingMore ||
        !_hasMore ||
        !state.hasValue) {
      return;
    }

    final loadSerial = _loadSerial;
    final activeSid = _activeSid;
    _isLoadingMore = true;
    state = AsyncData(List<ChatConversation>.from(state.value ?? const []));

    try {
      final repo = ref.read(chatRepositoryProvider);
      final res = await repo.getConversations(offset: _nextOffset);
      if (!mounted || loadSerial != _loadSerial || activeSid != _activeSid) {
        return;
      }

      if (res.isLeft) {
        appLogger.w(
          '[ConversationsController] loadMore failed: ${res.leftOrNull}',
        );
        return;
      }

      final page = List<ChatConversation>.from(res.rightOrNull ?? const []);
      _nextOffset += page.length;
      _hasMore = page.length >= _pageSize;

      final byId = <String, ChatConversation>{
        for (final conversation in state.value ?? const <ChatConversation>[])
          conversation.id: conversation,
      };
      for (final conversation in page) {
        byId.putIfAbsent(conversation.id, () => conversation);
      }

      final merged = byId.values.toList()..sort(_compareConversations);
      state = AsyncData(merged);
    } finally {
      _isLoadingMore = false;
      if (mounted &&
          loadSerial == _loadSerial &&
          activeSid == _activeSid &&
          state.hasValue) {
        state = AsyncData(List<ChatConversation>.from(state.value ?? const []));
      }
    }
  }

  Future<bool> markAllRead() async {
    final auth = ref.read(authControllerProvider);
    if (auth is! AuthAuthenticated) return false;

    final activeSid = _activeSid;
    final loadSerial = _loadSerial;
    final repo = ref.read(chatRepositoryProvider);
    final all = <String, ChatConversation>{};
    var offset = 0;

    while (true) {
      final res = await repo.getConversations(limit: 50, offset: offset);
      if (!mounted || activeSid != _activeSid || loadSerial != _loadSerial) {
        return false;
      }
      if (res.isLeft) return false;
      final page = res.rightOrNull ?? const <ChatConversation>[];
      for (final conversation in page) {
        all[conversation.id] = conversation;
      }
      offset += page.length;
      if (page.length < 50) break;
    }

    var allSucceeded = true;
    for (final conversation in all.values.where(
      (item) => item.unreadCount > 0,
    )) {
      final result = await repo.markRead(conversation.id);
      if (!mounted || activeSid != _activeSid || loadSerial != _loadSerial) {
        return false;
      }
      if (result.isLeft) {
        allSucceeded = false;
        continue;
      }
      markConversationAsReadLocally(conversation.id);
    }

    return allSucceeded;
  }

  Future<ConversationBulkActionResult> markConversationsRead(
    Iterable<String> conversationIds,
  ) async {
    final ids = _cleanConversationIds(conversationIds);
    final auth = ref.read(authControllerProvider);
    if (auth is! AuthAuthenticated || ids.isEmpty) {
      return ConversationBulkActionResult(
        succeededIds: const <String>{},
        failedIds: ids,
      );
    }

    final activeSid = _activeSid;
    final loadSerial = _loadSerial;
    final repo = ref.read(chatRepositoryProvider);
    final succeeded = <String>{};
    final failed = <String>{};
    final conversations = <String, ChatConversation>{
      for (final conversation in state.value ?? const <ChatConversation>[])
        conversation.id: conversation,
    };

    for (final id in ids) {
      if (!_isSameListSession(activeSid, loadSerial)) {
        failed.addAll(ids.difference(succeeded));
        break;
      }

      if ((conversations[id]?.unreadCount ?? 0) == 0) {
        succeeded.add(id);
        continue;
      }

      final result = await repo.markRead(id);
      if (!_isSameListSession(activeSid, loadSerial)) {
        failed.addAll(ids.difference(succeeded));
        break;
      }
      if (result.isLeft) {
        failed.add(id);
        continue;
      }

      succeeded.add(id);
      markConversationAsReadLocally(id);
    }

    return ConversationBulkActionResult(
      succeededIds: Set.unmodifiable(succeeded),
      failedIds: Set.unmodifiable(failed),
    );
  }

  Future<ConversationBulkActionResult> clearConversations(
    Iterable<String> conversationIds,
  ) async {
    final ids = _cleanConversationIds(conversationIds);
    final auth = ref.read(authControllerProvider);
    if (auth is! AuthAuthenticated || ids.isEmpty) {
      return ConversationBulkActionResult(
        succeededIds: const <String>{},
        failedIds: ids,
      );
    }

    final activeSid = _activeSid;
    final loadSerial = _loadSerial;
    final repo = ref.read(chatRepositoryProvider);
    final succeeded = <String>{};
    final failed = <String>{};

    for (final id in ids) {
      if (!_isSameListSession(activeSid, loadSerial)) {
        failed.addAll(ids.difference(succeeded));
        break;
      }
      final result = await repo.clearChat(id);
      if (!_isSameListSession(activeSid, loadSerial)) {
        failed.addAll(ids.difference(succeeded));
        break;
      }
      if (result.isLeft) {
        failed.add(id);
        continue;
      }

      succeeded.add(id);
      _markConversationClearedLocally(id);
    }

    if (succeeded.isNotEmpty && _isSameListSession(activeSid, loadSerial)) {
      await load();
    }

    return ConversationBulkActionResult(
      succeededIds: Set.unmodifiable(succeeded),
      failedIds: Set.unmodifiable(failed),
    );
  }

  Future<ConversationBulkActionResult> deleteConversations(
    Iterable<String> conversationIds,
  ) async {
    final ids = _cleanConversationIds(conversationIds);
    final auth = ref.read(authControllerProvider);
    if (auth is! AuthAuthenticated || ids.isEmpty) {
      return ConversationBulkActionResult(
        succeededIds: const <String>{},
        failedIds: ids,
      );
    }

    final activeSid = _activeSid;
    final loadSerial = _loadSerial;
    final repo = ref.read(chatRepositoryProvider);
    final succeeded = <String>{};
    final failed = <String>{};

    for (final id in ids) {
      if (!_isSameListSession(activeSid, loadSerial)) {
        failed.addAll(ids.difference(succeeded));
        break;
      }
      final result = await repo.deleteConversation(id);
      if (!_isSameListSession(activeSid, loadSerial)) {
        failed.addAll(ids.difference(succeeded));
        break;
      }
      if (result.isLeft) {
        failed.add(id);
        continue;
      }
      succeeded.add(id);
      state = state.whenData(
        (conversations) => conversations
            .where((conversation) => conversation.id != id)
            .toList(growable: false),
      );
    }

    return ConversationBulkActionResult(
      succeededIds: Set.unmodifiable(succeeded),
      failedIds: Set.unmodifiable(failed),
    );
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

    final activeSid = _activeSid;
    final loadSerial = _loadSerial;
    final repo = ref.read(chatRepositoryProvider);
    final previousState = state;

    state = state.whenData((conversations) {
      return conversations.where((c) => c.id != cleanId).toList();
    });

    final res = await repo.deleteConversation(cleanId);

    if (!mounted || activeSid != _activeSid || loadSerial != _loadSerial) {
      return false;
    }

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
      lastMessageId: message.id,
      lastMessageAt: message.createdAt,
      lastSender: message.senderCanonicalId,
      lastSenderDisplayName: message.senderDisplayName,
      lastSenderAvatar: message.senderAvatar,
      lastMessageDeliveredAt: message.deliveredAt,
      lastMessageReadAt: message.readAt,
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

      final sender = normalizeCanonicalUserId(message.senderCanonicalId);
      final shouldIncrement = sender.isNotEmpty && sender != _currentUser;

      syncConversationWithMessage(
        conversationId: conversationId,
        message: message,
        incrementUnread: shouldIncrement,
        fallbackUser: shouldIncrement ? message.senderCanonicalId : null,
        fallbackDisplayName: message.senderDisplayName,
        fallbackAvatar: message.senderAvatar,
      );
    });

    _messageStatusSub = realtime.messageStatus.listen((Object? data) {
      final payload = asJsonMap(data);
      final conversationId = payload['conversation_id']?.toString().trim();
      final messageIds = asJsonList(payload['message_ids'])
          .map((id) => id.toString().trim())
          .where((id) => id.isNotEmpty)
          .toSet();
      if (conversationId == null ||
          conversationId.isEmpty ||
          messageIds.isEmpty) {
        return;
      }

      final deliveredAt = _parseRealtimeDate(payload['delivered_at']);
      final readAt = _parseRealtimeDate(payload['read_at']);
      if (deliveredAt == null && readAt == null) return;

      state = state.whenData((conversations) {
        return conversations.map((conversation) {
          if (conversation.id != conversationId) return conversation;
          return conversation.applyLastMessageStatus(
            messageIds: messageIds,
            deliveredAt: deliveredAt,
            readAt: readAt,
          );
        }).toList(growable: false);
      });
    });

    _messageEditedSub = realtime.messageEdited.listen((Object? data) {
      final payload = asJsonMap(data);
      final conversationId = payload['conversation_id']?.toString();
      final rawMessage = payload['message'];

      if (conversationId == null || conversationId.trim().isEmpty) return;
      if (rawMessage is! Map) return;

      final message = ChatMessage.fromJson(asJsonMap(rawMessage));
      final conversation = state.value?.cast<ChatConversation?>().firstWhere(
        (item) => item?.id == conversationId,
        orElse: () => null,
      );
      if (conversation?.lastMessageId != message.id) return;

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
    await _messageStatusSub?.cancel();
    await _messageEditedSub?.cancel();
    await _messagesDeletedSub?.cancel();

    _messageSub = null;
    _messageStatusSub = null;
    _messageEditedSub = null;
    _messagesDeletedSub = null;
  }

  // -----------------------------
  // Internal preview upsert
  // -----------------------------
  void _upsertConversationPreview({
    required String conversationId,
    required String lastMessage,
    required String lastMessageId,
    required DateTime lastMessageAt,
    required String lastSender,
    String? lastSenderDisplayName,
    String? lastSenderAvatar,
    DateTime? lastMessageDeliveredAt,
    DateTime? lastMessageReadAt,
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
        lastMessageId: lastMessageId,
        lastMessageAt: lastMessageAt,
        lastSender: normalizeCanonicalUserId(lastSender),
        lastSenderDisplayName: _safeText(lastSenderDisplayName),
        lastSenderAvatar: _safeText(lastSenderAvatar),
        lastMessageDeliveredAt: lastMessageDeliveredAt,
        lastMessageReadAt: lastMessageReadAt,
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

    final canonicalFallbackUser = normalizeCanonicalUserId(fallbackUser);
    final canonicalLastSender = normalizeCanonicalUserId(lastSender);
    final newConversation = ChatConversation(
      id: conversationId,
      user: canonicalFallbackUser.isNotEmpty
          ? canonicalFallbackUser
          : canonicalLastSender,
      displayName:
          _safeText(fallbackDisplayName) ??
          _safeText(lastSenderDisplayName) ??
          (canonicalFallbackUser.isNotEmpty
              ? canonicalFallbackUser
              : conversationId),
      avatar: _safeText(fallbackAvatar),
      lastMessage: lastMessage,
      lastMessageId: lastMessageId,
      lastMessageAt: lastMessageAt,
      lastSender: canonicalLastSender,
      lastSenderDisplayName: _safeText(lastSenderDisplayName),
      lastSenderAvatar: _safeText(lastSenderAvatar),
      lastMessageDeliveredAt: lastMessageDeliveredAt,
      lastMessageReadAt: lastMessageReadAt,
      unreadCount: incrementUnread ? 1 : 0,
    );

    state = AsyncData(<ChatConversation>[newConversation, ...current]);
  }

  int _compareConversations(ChatConversation a, ChatConversation b) {
    final aTime = a.lastMessageAt;
    final bTime = b.lastMessageAt;
    if (aTime == null && bTime == null) return a.id.compareTo(b.id);
    if (aTime == null) return 1;
    if (bTime == null) return -1;
    final byTime = bTime.compareTo(aTime);
    return byTime != 0 ? byTime : a.id.compareTo(b.id);
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

  String? _safeText(String? value) {
    final clean = value?.trim();
    if (clean == null || clean.isEmpty || clean.toLowerCase() == 'null') {
      return null;
    }

    return clean;
  }

  Set<String> _cleanConversationIds(Iterable<String> conversationIds) {
    return conversationIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  bool _isSameListSession(String? activeSid, int loadSerial) {
    return mounted && activeSid == _activeSid && loadSerial == _loadSerial;
  }

  void _markConversationClearedLocally(String conversationId) {
    state = state.whenData((conversations) {
      return conversations.map((conversation) {
        if (conversation.id != conversationId) return conversation;
        return conversation.copyWith(
          lastMessage: null,
          lastMessageId: null,
          lastMessageAt: null,
          lastSender: null,
          lastSenderDisplayName: null,
          lastSenderAvatar: null,
          lastMessageDeliveredAt: null,
          lastMessageReadAt: null,
          unreadCount: 0,
        );
      }).toList(growable: false);
    });
  }

  DateTime? _parseRealtimeDate(Object? value) {
    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty || raw.toLowerCase() == 'null') {
      return null;
    }
    return DateTime.tryParse(raw.replaceFirst(' ', 'T'));
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
