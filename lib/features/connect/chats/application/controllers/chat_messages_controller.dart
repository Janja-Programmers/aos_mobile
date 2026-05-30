import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/connect/chats/application/providers/chat_providers.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_attachment.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message_reaction.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message_viewer_state.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_reply_preview.dart';
import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_input_controller.dart';
import 'package:africaonlinestores/features/connect/chats/repository/chat_repository_impl.dart';
import 'package:africaonlinestores/features/connect/converaation/application/providers/conversation_provider.dart';

class ChatMessagesController
    extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final Ref ref;
  final String conversationId;
  late final String currentUser;

  ChatMessagesController(this.ref, this.conversationId)
    : super(const AsyncLoading()) {
    currentUser = ref.read(currentUserProvider) ?? '';
    _init();
  }

  final List<ChatMessage> _messages = [];
  StreamSubscription? _messageSub;
  StreamSubscription? _messageStatusSub;
  StreamSubscription? _messageEditedSub;
  StreamSubscription? _messagesDeletedSub;
  StreamSubscription? _messageReactionSub;

  Timer? _readSyncDebounce;
  bool _isSyncingReadState = false;

  Future<void> _init() async {
    await loadInitial();
    await _listenRealtime();
  }

  Future<void> loadInitial() async {
    final repo = ref.read(chatRepositoryProvider);
    final res = await repo.getMessages(conversationId: conversationId);

    if (res.isLeft) {
      state = AsyncError(res.leftOrNull!, StackTrace.current);
      return;
    }

    _messages
      ..clear()
      ..addAll(res.rightOrNull!.reversed);

    state = AsyncData(List.of(_messages));
    await _syncIncomingReadState();
  }

  Future<void> loadMore() async {
    if (_messages.isEmpty) return;

    final repo = ref.read(chatRepositoryProvider);
    final oldest = _messages.first;

    final res = await repo.getMessages(
      conversationId: conversationId,
      before: oldest.id,
    );

    if (res.isLeft) return;

    final existingIds = _messages.map((m) => m.id).toSet();
    final older = res.rightOrNull!
        .where((message) => !existingIds.contains(message.id))
        .toList()
        .reversed;

    _messages.insertAll(0, older);
    state = AsyncData(List.of(_messages));
  }

  Future<bool> sendTempMessage({
    String? text,
    String? adId,
    String? adTitle,
    String? adPrice,
    String? adImage,
    String? adImageFileId,
    String? senderId,
    String? fallbackUser,
    String? fallbackDisplayName,
    String? fallbackAvatar,
    String? replyToMessage,
    ChatReplyPreview? replyTo,
    List<ChatInputAttachment> attachments = const [],
  }) async {
    final safeSenderId = senderId?.trim().toLowerCase();

    if (safeSenderId == null || safeSenderId.isEmpty) return false;

    final trimmedText = text?.trim();
    final hasText = trimmedText != null && trimmedText.isNotEmpty;
    final hasAttachments = attachments.isNotEmpty;
    final hasAd = adId != null && adId.trim().isNotEmpty;

    if (!hasText && !hasAttachments && !hasAd) return false;

    final tempId = 'temp-${DateTime.now().microsecondsSinceEpoch}';

    final validAttachments = attachments
        .where((a) => a.fileId.trim().isNotEmpty && a.type.trim().isNotEmpty)
        .toList();

    final apiAttachments = validAttachments
        .map((a) => a.toApi(ad: hasAd ? adId : null))
        .toList();

    final tempAttachments = validAttachments.asMap().entries.map((entry) {
      final index = entry.key;
      final attachment = entry.value;

      return ChatAttachment(
        url: attachment.previewUrl.trim().isNotEmpty
            ? attachment.previewUrl.trim()
            : attachment.fileId.trim(),
        type: attachment.type.trim(),
        sortOrder: index,
      );
    }).toList();

    final tempAdPreview = hasAd
        ? {'title': adTitle, 'price': adPrice, 'image': adImage}
        : null;

    final tempMessage = ChatMessage.temp(
      id: tempId,
      sender: safeSenderId,
      content: trimmedText,
      attachments: tempAttachments,
      ad: hasAd ? adId : null,
      adPreview: tempAdPreview,
      replyToMessage: replyToMessage,
      replyTo: replyTo,
    );

    _messages.add(tempMessage);
    state = AsyncData(List.of(_messages));

    final realMsg = await sendMessage(
      text: trimmedText,
      ad: hasAd ? adId : null,
      replyToMessage: replyToMessage,
      attachments: apiAttachments,
    );

    if (realMsg == null) {
      _messages.removeWhere((m) => m.id == tempId);
      state = AsyncData(List.of(_messages));
      return false;
    }

    final index = _messages.indexWhere((m) => m.id == tempId);
    if (index != -1) {
      _messages[index] = realMsg;
    } else if (!_isDuplicate(realMsg)) {
      _messages.add(realMsg);
    }

    state = AsyncData(List.of(_messages));

    ref
        .read(conversationsControllerProvider.notifier)
        .syncConversationWithMessage(
          conversationId: conversationId,
          message: realMsg,
          fallbackUser: fallbackUser,
          fallbackDisplayName: fallbackDisplayName,
          fallbackAvatar: fallbackAvatar,
          incrementUnread: false,
        );

    return true;
  }

  Future<ChatMessage?> sendMessage({
    String? text,
    String? ad,
    String? replyToMessage,
    List<Map<String, dynamic>> attachments = const [],
  }) async {
    final repo = ref.read(chatRepositoryProvider);
    final trimmedText = text?.trim();

    final hasText = trimmedText != null && trimmedText.isNotEmpty;
    final hasAttachments = attachments.isNotEmpty;
    final hasAd = ad != null && ad.trim().isNotEmpty;

    if (!hasText && !hasAttachments && !hasAd) return null;

    final res = await repo.sendMessage(
      conversationId: conversationId,
      content: hasText ? trimmedText : null,
      ad: hasAd ? ad.trim() : null,
      replyToMessage: replyToMessage,
      attachments: List<Map<String, dynamic>>.from(attachments),
    );

    if (res.isLeft) return null;
    return res.rightOrNull!;
  }

  Future<bool> editMessage({
    required String messageId,
    required String content,
  }) async {
    final cleanContent = content.trim();
    if (messageId.trim().isEmpty || cleanContent.isEmpty) return false;

    final repo = ref.read(chatRepositoryProvider);
    final res = await repo.editMessage(
      messageId: messageId,
      content: cleanContent,
    );

    if (res.isLeft) return false;

    _upsertMessage(res.rightOrNull!);
    return true;
  }

  Future<bool> deleteMessages({
    required List<String> messageIds,
    required String deleteScope,
  }) async {
    final ids = messageIds
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (ids.isEmpty) return false;

    final repo = ref.read(chatRepositoryProvider);
    final res = await repo.deleteMessages(
      messageIds: ids,
      deleteScope: deleteScope,
    );
    if (res.isLeft) return false;

    final data = res.rightOrNull ?? <String, dynamic>{};
    final returnedIds = _readMessageIds(data['message_ids']);
    final effectiveIds = returnedIds.isEmpty ? ids : returnedIds;
    final scope = data['delete_scope']?.toString() ?? deleteScope;
    final displayText = data['display_text']?.toString();

    if (scope == 'everyone') {
      _markMessagesDeletedForEveryone(effectiveIds, displayText: displayText);
    } else {
      _removeMessages(effectiveIds);
    }

    await ref.read(conversationsControllerProvider.notifier).load();
    return true;
  }

  Future<bool> clearChat() async {
    final repo = ref.read(chatRepositoryProvider);
    final res = await repo.clearChat(conversationId);
    if (res.isLeft) return false;

    _messages.clear();
    state = const AsyncData([]);
    await ref.read(conversationsControllerProvider.notifier).load();
    return true;
  }

  Future<bool> toggleMessageStar(String messageId) async {
    final index = _messages.indexWhere((message) => message.id == messageId);
    if (index == -1) return false;

    final repo = ref.read(chatRepositoryProvider);
    final res = await repo.toggleMessageStar(messageId);
    if (res.isLeft) return false;

    final current = _messages[index];
    _messages[index] = current.copyWith(
      viewerState: current.viewerState.copyWith(
        isStarred: res.rightOrNull ?? false,
      ),
    );
    state = AsyncData(List.of(_messages));
    return true;
  }

  Future<bool> toggleMessageReaction({
    required String messageId,
    required String? emoji,
  }) async {
    final repo = ref.read(chatRepositoryProvider);
    final res = await repo.toggleMessageReaction(
      messageId: messageId,
      emoji: emoji,
    );
    if (res.isLeft) return false;

    _applyReactionPayload(res.rightOrNull ?? <String, dynamic>{});
    return true;
  }

  Future<bool> forwardMessage({
    required String messageId,
    required List<String> targetConversationIds,
  }) async {
    final repo = ref.read(chatRepositoryProvider);
    final res = await repo.forwardMessage(
      messageId: messageId,
      targetConversationIds: targetConversationIds,
    );
    return res.isRight;
  }

  Future<void> _listenRealtime() async {
    final realtime = ref.read(chatRealtimeServiceProvider);

    await _messageSub?.cancel();
    await _messageStatusSub?.cancel();
    await _messageEditedSub?.cancel();
    await _messagesDeletedSub?.cancel();
    await _messageReactionSub?.cancel();

    _messageSub = realtime.messages.listen((data) async {
      final convId = data['conversation_id'];
      if (convId != conversationId) return;

      final msgData = data['message'];
      if (msgData == null) return;

      final newMsg = ChatMessage.fromJson(Map<String, dynamic>.from(msgData));

      _messages.removeWhere((m) => _isSameTemp(m, newMsg));
      if (_isDuplicate(newMsg)) return;

      _messages.add(newMsg);
      state = AsyncData(List.of(_messages));

      if (_isIncomingMessage(newMsg)) {
        _scheduleIncomingReadSync();
      }
    });

    _messageStatusSub = realtime.messageStatus.listen((data) {
      final convId = data['conversation_id'];
      if (convId != conversationId) return;
      _applyMessageStatus(Map<String, dynamic>.from(data));
    });

    _messageEditedSub = realtime.messageEdited.listen((data) {
      final convId = data['conversation_id'];
      if (convId != conversationId) return;
      final msgData = data['message'];
      if (msgData is! Map) return;
      _upsertMessage(ChatMessage.fromJson(Map<String, dynamic>.from(msgData)));
    });

    _messagesDeletedSub = realtime.messagesDeleted.listen((data) async {
      final convId = data['conversation_id'];
      if (convId != conversationId) return;

      final payload = Map<String, dynamic>.from(data);
      final ids = _readMessageIds(payload['message_ids']);
      final displayText = payload['display_text']?.toString();

      _markMessagesDeletedForEveryone(ids, displayText: displayText);
      await ref.read(conversationsControllerProvider.notifier).load();
    });

    _messageReactionSub = realtime.messageReactionUpdated.listen((data) {
      final convId = data['conversation_id'];
      if (convId != conversationId) return;
      _applyReactionPayload(Map<String, dynamic>.from(data));
    });
  }

  void _applyMessageStatus(Map<String, dynamic> data) {
    final status = data['status']?.toString();
    final rawMessageIds = data['message_ids'];

    if (status == null || rawMessageIds is! List || rawMessageIds.isEmpty) {
      return;
    }

    final messageIds = rawMessageIds.map((e) => e.toString()).toSet();
    final deliveredAt = DateTime.tryParse(
      data['delivered_at']?.toString() ?? '',
    );
    final readAt = DateTime.tryParse(data['read_at']?.toString() ?? '');

    var changed = false;

    for (var i = 0; i < _messages.length; i++) {
      final message = _messages[i];
      if (!messageIds.contains(message.id)) continue;

      if (status == 'delivered' && message.deliveredAt == null) {
        _messages[i] = message.copyWith(
          deliveredAt: deliveredAt ?? DateTime.now(),
        );
        changed = true;
      }

      if (status == 'read' && message.readAt == null) {
        final effectiveReadAt = readAt ?? DateTime.now();
        _messages[i] = message.copyWith(
          deliveredAt: message.deliveredAt ?? effectiveReadAt,
          readAt: effectiveReadAt,
        );
        changed = true;
      }
    }

    if (changed) state = AsyncData(List.of(_messages));
  }

  void _applyReactionPayload(Map<String, dynamic> data) {
    final messageId = data['message_id']?.toString();
    if (messageId == null || messageId.isEmpty) return;

    final index = _messages.indexWhere((message) => message.id == messageId);
    if (index == -1) return;

    final current = _messages[index];
    final rawReactions = data['reactions'];
    final reactions = (rawReactions is List ? rawReactions : const [])
        .whereType<Map>()
        .map((e) => ChatMessageReaction.fromJson(Map<String, dynamic>.from(e)))
        .where((reaction) => reaction.emoji.trim().isNotEmpty)
        .toList();

    final rawViewerState = data['viewer_state'];
    final viewerState = rawViewerState is Map
        ? ChatMessageViewerState.fromJson(
            Map<String, dynamic>.from(rawViewerState),
          )
        : current.viewerState.copyWith(myReaction: data['emoji']?.toString());

    _messages[index] = current.copyWith(
      reactions: reactions,
      viewerState: current.viewerState.copyWith(
        myReaction: viewerState.myReaction,
      ),
    );

    state = AsyncData(List.of(_messages));
  }

  void _upsertMessage(ChatMessage message) {
    final index = _messages.indexWhere((existing) => existing.id == message.id);

    if (index == -1) {
      _messages.add(message);
    } else {
      _messages[index] = message;
    }

    state = AsyncData(List.of(_messages));
  }

  void _removeMessages(List<String> messageIds) {
    final ids = messageIds.toSet();
    _messages.removeWhere((message) => ids.contains(message.id));
    state = AsyncData(List.of(_messages));
  }

  void _markMessagesDeletedForEveryone(
    List<String> messageIds, {
    String? displayText,
  }) {
    if (messageIds.isEmpty) return;

    final ids = messageIds.toSet();
    var changed = false;

    for (var i = 0; i < _messages.length; i++) {
      final message = _messages[i];
      if (!ids.contains(message.id)) continue;

      _messages[i] = message.asDeletedPlaceholder(displayText: displayText);
      changed = true;
    }

    if (changed) state = AsyncData(List.of(_messages));
  }

  List<String> _readMessageIds(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return [value.trim()];
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }

  bool _isIncomingMessage(ChatMessage message) {
    return message.sender.trim().toLowerCase() !=
        currentUser.trim().toLowerCase();
  }

  void _scheduleIncomingReadSync() {
    _readSyncDebounce?.cancel();
    _readSyncDebounce = Timer(const Duration(milliseconds: 250), () {
      _syncIncomingReadState();
    });
  }

  Future<void> _syncIncomingReadState() async {
    if (_isSyncingReadState) return;
    _isSyncingReadState = true;

    try {
      final repo = ref.read(chatRepositoryProvider);
      final hasIncomingUnread = _messages.any((message) {
        return _isIncomingMessage(message) && message.readAt == null;
      });

      if (!hasIncomingUnread) {
        ref
            .read(conversationsControllerProvider.notifier)
            .markConversationAsReadLocally(conversationId);
        return;
      }

      final deliveredRes = await repo.markDelivered(conversationId);
      final readRes = await repo.markRead(conversationId);

      if (readRes.isRight) {
        final now = DateTime.now();
        _markIncomingMessagesReadLocally(now);
        ref
            .read(conversationsControllerProvider.notifier)
            .markConversationAsReadLocally(conversationId);
      }

      if (deliveredRes.isLeft || readRes.isLeft) {
        // Silent best-effort failure. Backend/realtime/next refresh can resync.
      }
    } finally {
      _isSyncingReadState = false;
    }
  }

  void _markIncomingMessagesReadLocally(DateTime timestamp) {
    var changed = false;

    for (var i = 0; i < _messages.length; i++) {
      final message = _messages[i];
      if (!_isIncomingMessage(message)) continue;

      final shouldUpdateDelivered = message.deliveredAt == null;
      final shouldUpdateRead = message.readAt == null;
      if (!shouldUpdateDelivered && !shouldUpdateRead) continue;

      _messages[i] = message.copyWith(
        deliveredAt: message.deliveredAt ?? timestamp,
        readAt: message.readAt ?? timestamp,
      );
      changed = true;
    }

    if (changed) state = AsyncData(List.of(_messages));
  }

  bool _isDuplicate(ChatMessage newMsg) {
    return _messages.any((m) => m.id == newMsg.id);
  }

  bool _isSameTemp(ChatMessage temp, ChatMessage real) {
    if (!temp.id.startsWith('temp-')) return false;
    if (temp.sender != real.sender) return false;

    final sameText = temp.content == real.content;
    final sameReply = temp.replyToMessage == real.replyToMessage;
    final sameAttachments = temp.attachments.length == real.attachments.length;

    return sameText && sameReply && sameAttachments;
  }

  @override
  void dispose() {
    _readSyncDebounce?.cancel();
    _messageSub?.cancel();
    _messageStatusSub?.cancel();
    _messageEditedSub?.cancel();
    _messagesDeletedSub?.cancel();
    _messageReactionSub?.cancel();
    super.dispose();
  }
}
