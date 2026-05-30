import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/connect/chats/application/providers/chat_providers.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_attachment.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_local_message_status.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message_reaction.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message_viewer_state.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_reply_preview.dart';
import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_input_controller.dart';
import 'package:africaonlinestores/features/connect/chats/domain/pending_send_payload.dart';
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

  // ---------------------------------------------------------------------------
  // Local state
  // ---------------------------------------------------------------------------

  final List<ChatMessage> _messages = [];
  final Map<String, PendingSendPayload> _pendingSends = {};

  final Set<String> _translatingMessageIds = {};
  final Map<String, String> _translationErrors = {};

  StreamSubscription? _messageSub;
  StreamSubscription? _messageStatusSub;
  StreamSubscription? _messageEditedSub;
  StreamSubscription? _messagesDeletedSub;
  StreamSubscription? _messageReactionSub;

  Timer? _readSyncDebounce;
  bool _isSyncingReadState = false;

  // ---------------------------------------------------------------------------
  // Lifecycle / initial loading
  // ---------------------------------------------------------------------------

  Future<void> _init() async {
    await _listenRealtime();
    await loadInitial();
  }

  Future<void> loadInitial() async {
    final repo = ref.read(chatRepositoryProvider);

    final res = await repo.getMessages(conversationId: conversationId);

    if (res.isLeft) {
      if (_messages.isEmpty) {
        state = AsyncError(res.leftOrNull!, StackTrace.current);
      }
      return;
    }

    final serverMessages = List<ChatMessage>.from(res.rightOrNull ?? []);

    _mergeServerMessages(serverMessages);
    _emitMessages();

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

    final olderMessages = List<ChatMessage>.from(res.rightOrNull ?? []);

    for (final message in olderMessages.reversed) {
      _upsertMessage(message, emit: false);
    }

    _sortMessages();
    _emitMessages();
  }

  // ---------------------------------------------------------------------------
  // Sending / retry
  // ---------------------------------------------------------------------------

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

    if (safeSenderId == null || safeSenderId.isEmpty) {
      return false;
    }

    final trimmedText = text?.trim();
    final hasText = trimmedText != null && trimmedText.isNotEmpty;
    final hasAttachments = attachments.isNotEmpty;
    final hasAd = adId != null && adId.trim().isNotEmpty;

    if (!hasText && !hasAttachments && !hasAd) {
      return false;
    }

    final tempId = 'temp-${DateTime.now().microsecondsSinceEpoch}';

    final validAttachments = attachments.where((attachment) {
      return attachment.fileId.trim().isNotEmpty &&
          attachment.type.trim().isNotEmpty;
    }).toList();

    final apiAttachments = validAttachments
        .map((attachment) => attachment.toApi(ad: hasAd ? adId : null))
        .toList();

    _pendingSends[tempId] = PendingSendPayload(
      tempId: tempId,
      text: trimmedText,
      ad: hasAd ? adId.trim() : null,
      attachments: apiAttachments,
      fallbackUser: fallbackUser,
      fallbackDisplayName: fallbackDisplayName,
      fallbackAvatar: fallbackAvatar,
    );

    final tempMessage = _buildTempMessage(
      tempId: tempId,
      sender: safeSenderId,
      text: trimmedText,
      adId: hasAd ? adId : null,
      adTitle: adTitle,
      adPrice: adPrice,
      adImage: adImage,
      attachments: validAttachments,
    );

    _upsertMessage(tempMessage);

    final realMsg = await sendMessage(
      text: trimmedText,
      ad: hasAd ? adId : null,
      replyToMessage: replyToMessage,
      attachments: apiAttachments,
    );

    if (realMsg == null) {
      _markTempMessageFailed(tempId, error: 'Failed to send. Tap to retry.');
      return true;
    }

    _upsertMessage(realMsg);
    _pendingSends.remove(tempId);

    _syncConversationPreview(
      message: realMsg,
      fallbackUser: fallbackUser,
      fallbackDisplayName: fallbackDisplayName,
      fallbackAvatar: fallbackAvatar,
    );

    return true;
  }

  Future<ChatMessage?> sendMessage({
    String? text,
    String? ad,
    String? replyToMessage,
    List<Map<String, dynamic>> attachments = const [],
  }) async {
    final trimmedText = text?.trim();

    final hasText = trimmedText != null && trimmedText.isNotEmpty;
    final hasAttachments = attachments.isNotEmpty;
    final hasAd = ad != null && ad.trim().isNotEmpty;

    if (!hasText && !hasAttachments && !hasAd) {
      return null;
    }

    final repo = ref.read(chatRepositoryProvider);

    final res = await repo.sendMessage(
      conversationId: conversationId,
      content: hasText ? trimmedText : null,
      ad: hasAd ? ad.trim() : null,
      replyToMessage: replyToMessage,
      attachments: List<Map<String, dynamic>>.from(attachments),
    );

    if (res.isLeft) return null;

    return res.rightOrNull;
  }

  Future<bool> retryMessage(String tempId) async {
    final payload = _pendingSends[tempId];

    if (payload == null) {
      _markTempMessageFailed(tempId, error: 'Could not retry this message.');
      return false;
    }

    final index = _messages.indexWhere((message) => message.id == tempId);

    if (index == -1) {
      return false;
    }

    _messages[index] = _messages[index].copyWith(
      localStatus: ChatLocalMessageStatus.sending,
      clearLocalError: true,
    );

    _emitMessages();

    final realMsg = await sendMessage(
      text: payload.text,
      ad: payload.ad,
      attachments: payload.attachments,
    );

    if (realMsg == null) {
      _markTempMessageFailed(tempId, error: 'Still failed. Tap to retry.');
      return false;
    }

    _upsertMessage(realMsg);
    _pendingSends.remove(tempId);

    _syncConversationPreview(
      message: realMsg,
      fallbackUser: payload.fallbackUser,
      fallbackDisplayName: payload.fallbackDisplayName,
      fallbackAvatar: payload.fallbackAvatar,
    );

    return true;
  }

  ChatMessage _buildTempMessage({
    required String tempId,
    required String sender,
    required String? text,
    required String? adId,
    required String? adTitle,
    required String? adPrice,
    required String? adImage,
    required List<ChatInputAttachment> attachments,
  }) {
    final tempAttachments = attachments.asMap().entries.map((entry) {
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

    final tempAdPreview = adId != null
        ? {'title': adTitle, 'price': adPrice, 'image': adImage}
        : null;

    return ChatMessage.temp(
      id: tempId,
      sender: sender,
      content: text,
      attachments: tempAttachments,
      ad: adId,
      adPreview: tempAdPreview,
    ).copyWith(
      localStatus: ChatLocalMessageStatus.sending,
      clearLocalError: true,
    );
  }

  void _markTempMessageFailed(String tempId, {required String error}) {
    final index = _messages.indexWhere((message) => message.id == tempId);

    if (index == -1) return;

    _messages[index] = _messages[index].copyWith(
      localStatus: ChatLocalMessageStatus.failed,
      localError: error,
    );

    _emitMessages();
  }

  // ---------------------------------------------------------------------------
  // Message actions
  // ---------------------------------------------------------------------------

  Future<bool> editMessage({
    required String messageId,
    required String content,
  }) async {
    final cleanMessageId = messageId.trim();
    final cleanContent = content.trim();

    if (cleanMessageId.isEmpty || cleanContent.isEmpty) {
      return false;
    }

    final repo = ref.read(chatRepositoryProvider);

    final res = await repo.editMessage(
      messageId: cleanMessageId,
      content: cleanContent,
    );

    if (res.isLeft) return false;

    final updated = res.rightOrNull;
    if (updated == null) return false;

    _upsertMessage(updated);
    return true;
  }

  Future<bool> deleteMessages({
    required List<String> messageIds,
    required String deleteScope,
  }) async {
    final ids = messageIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
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
    _pendingSends.clear();

    state = const AsyncData([]);

    await ref.read(conversationsControllerProvider.notifier).load();
    return true;
  }

  Future<bool> toggleMessageStar(String messageId) async {
    final cleanMessageId = messageId.trim();

    if (cleanMessageId.isEmpty) return false;

    final index = _messages.indexWhere(
      (message) => message.id == cleanMessageId,
    );

    if (index == -1) return false;

    final repo = ref.read(chatRepositoryProvider);
    final res = await repo.toggleMessageStar(cleanMessageId);

    if (res.isLeft) return false;

    final current = _messages[index];

    _messages[index] = current.copyWith(
      viewerState: current.viewerState.copyWith(
        isStarred: res.rightOrNull ?? false,
      ),
    );

    _emitMessages();
    return true;
  }

  Future<bool> toggleMessageReaction({
    required String messageId,
    required String? emoji,
  }) async {
    final cleanMessageId = messageId.trim();

    if (cleanMessageId.isEmpty) return false;

    final repo = ref.read(chatRepositoryProvider);

    final res = await repo.toggleMessageReaction(
      messageId: cleanMessageId,
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
    final cleanMessageId = messageId.trim();

    final cleanTargets = targetConversationIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList();

    if (cleanMessageId.isEmpty || cleanTargets.isEmpty) {
      return false;
    }

    final repo = ref.read(chatRepositoryProvider);

    final res = await repo.forwardMessage(
      messageId: cleanMessageId,
      targetConversationIds: cleanTargets,
    );

    return res.isRight;
  }

  // ---------------------------------------------------------------------------
  // Translation
  // ---------------------------------------------------------------------------

  bool isTranslatingMessage(String messageId) {
    return _translatingMessageIds.contains(messageId.trim());
  }

  String? translationErrorFor(String messageId) {
    return _translationErrors[messageId.trim()];
  }

  Future<bool> translateMessage({
    required String messageId,
    required String targetLanguage,
  }) async {
    final cleanMessageId = messageId.trim();
    final cleanTargetLanguage = targetLanguage.trim();

    if (cleanMessageId.isEmpty || cleanTargetLanguage.isEmpty) {
      return false;
    }

    if (_translatingMessageIds.contains(cleanMessageId)) {
      return false;
    }

    _translatingMessageIds.add(cleanMessageId);
    _translationErrors.remove(cleanMessageId);
    _emitMessages();

    final repo = ref.read(chatRepositoryProvider);

    final res = await repo.translateMessage(
      messageId: cleanMessageId,
      targetLanguage: cleanTargetLanguage,
    );

    _translatingMessageIds.remove(cleanMessageId);

    if (res.isLeft) {
      _translationErrors[cleanMessageId] = 'Failed to translate message.';
      _emitMessages();
      return false;
    }

    final data = res.rightOrNull ?? <String, dynamic>{};

    final translatedContent = data['translated_content']?.toString().trim();
    final translationLanguage =
        data['target_language_label']?.toString().trim() ??
        data['target_language']?.toString().trim();

    if (translatedContent == null || translatedContent.isEmpty) {
      _translationErrors[cleanMessageId] = 'No translation returned.';
      _emitMessages();
      return false;
    }

    final index = _messages.indexWhere(
      (message) => message.id == cleanMessageId,
    );

    if (index == -1) {
      _emitMessages();
      return false;
    }

    final current = _messages[index];

    _messages[index] = current.copyWith(
      translatedContent: translatedContent,
      translationLanguage: translationLanguage,
    );

    _translationErrors.remove(cleanMessageId);
    _emitMessages();

    return true;
  }

  void clearMessageTranslation(String messageId) {
    final cleanMessageId = messageId.trim();

    if (cleanMessageId.isEmpty) return;

    final index = _messages.indexWhere(
      (message) => message.id == cleanMessageId,
    );

    if (index == -1) return;

    _messages[index] = _messages[index].copyWith(clearTranslation: true);

    _translationErrors.remove(cleanMessageId);
    _emitMessages();
  }

  // ---------------------------------------------------------------------------
  // Realtime listeners
  // ---------------------------------------------------------------------------

  Future<void> _listenRealtime() async {
    final realtime = ref.read(chatRealtimeServiceProvider);

    await _cancelRealtimeSubscriptions();

    _messageSub = realtime.messages.listen((data) {
      _handleRealtimeMessage(Map<String, dynamic>.from(data));
    });

    _messageStatusSub = realtime.messageStatus.listen((data) {
      _handleRealtimeMessageStatus(Map<String, dynamic>.from(data));
    });

    _messageEditedSub = realtime.messageEdited.listen((data) {
      _handleRealtimeMessageEdited(Map<String, dynamic>.from(data));
    });

    _messagesDeletedSub = realtime.messagesDeleted.listen((data) async {
      await _handleRealtimeMessagesDeleted(Map<String, dynamic>.from(data));
    });

    _messageReactionSub = realtime.messageReactionUpdated.listen((data) {
      _handleRealtimeReactionUpdated(Map<String, dynamic>.from(data));
    });
  }

  Future<void> _cancelRealtimeSubscriptions() async {
    await _messageSub?.cancel();
    await _messageStatusSub?.cancel();
    await _messageEditedSub?.cancel();
    await _messagesDeletedSub?.cancel();
    await _messageReactionSub?.cancel();

    _messageSub = null;
    _messageStatusSub = null;
    _messageEditedSub = null;
    _messagesDeletedSub = null;
    _messageReactionSub = null;
  }

  void _handleRealtimeMessage(Map<String, dynamic> data) {
    final convId = data['conversation_id']?.toString();

    if (convId != conversationId) return;

    final msgData = data['message'];

    if (msgData is! Map) return;

    final newMsg = ChatMessage.fromJson(Map<String, dynamic>.from(msgData));

    _upsertMessage(newMsg);

    if (_isIncomingMessage(newMsg)) {
      _scheduleIncomingReadSync();
    }
  }

  void _handleRealtimeMessageStatus(Map<String, dynamic> data) {
    final convId = data['conversation_id']?.toString();

    if (convId != conversationId) return;

    _applyMessageStatus(data);
  }

  void _handleRealtimeMessageEdited(Map<String, dynamic> data) {
    final convId = data['conversation_id']?.toString();

    if (convId != conversationId) return;

    final msgData = data['message'];

    if (msgData is! Map) return;

    final message = ChatMessage.fromJson(Map<String, dynamic>.from(msgData));

    _upsertMessage(message);
  }

  Future<void> _handleRealtimeMessagesDeleted(Map<String, dynamic> data) async {
    final convId = data['conversation_id']?.toString();

    if (convId != conversationId) return;

    final ids = _readMessageIds(data['message_ids']);
    final displayText = data['display_text']?.toString();

    _markMessagesDeletedForEveryone(ids, displayText: displayText);

    await ref.read(conversationsControllerProvider.notifier).load();
  }

  void _handleRealtimeReactionUpdated(Map<String, dynamic> data) {
    final convId = data['conversation_id']?.toString();

    if (convId != conversationId) return;

    _applyReactionPayload(data);
  }

  // ---------------------------------------------------------------------------
  // Realtime payload appliers
  // ---------------------------------------------------------------------------

  void _applyMessageStatus(Map<String, dynamic> data) {
    final status = data['status']?.toString();
    final rawMessageIds = data['message_ids'];

    if (status == null || rawMessageIds is! List || rawMessageIds.isEmpty) {
      return;
    }

    final messageIds = rawMessageIds.map((id) => id.toString()).toSet();

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

    if (changed) {
      _emitMessages();
    }
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
        .map(
          (reaction) =>
              ChatMessageReaction.fromJson(Map<String, dynamic>.from(reaction)),
        )
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

    _emitMessages();
  }

  // ---------------------------------------------------------------------------
  // Local message list mutation
  // ---------------------------------------------------------------------------

  void _mergeServerMessages(List<ChatMessage> serverMessages) {
    for (final serverMessage in serverMessages.reversed) {
      _upsertMessage(serverMessage, emit: false);
    }

    _sortMessages();
  }

  void _upsertMessage(ChatMessage message, {bool emit = true}) {
    final existingIndex = _messages.indexWhere(
      (existing) => existing.id == message.id,
    );

    if (existingIndex != -1) {
      _messages[existingIndex] = message;
      _sortMessages();

      if (emit) _emitMessages();
      return;
    }

    final tempIndex = _messages.indexWhere(
      (existing) => _isSameTemp(existing, message),
    );

    if (tempIndex != -1) {
      final tempId = _messages[tempIndex].id;

      _messages[tempIndex] = message;
      _pendingSends.remove(tempId);

      _sortMessages();

      if (emit) _emitMessages();
      return;
    }

    _messages.add(message);
    _sortMessages();

    if (emit) _emitMessages();
  }

  void _removeMessages(List<String> messageIds) {
    if (messageIds.isEmpty) return;

    final ids = messageIds.toSet();

    _messages.removeWhere((message) => ids.contains(message.id));

    for (final id in ids) {
      _pendingSends.remove(id);
    }

    _emitMessages();
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

    if (changed) {
      _emitMessages();
    }
  }

  void _sortMessages() {
    _messages.sort((a, b) {
      return a.createdAt.compareTo(b.createdAt);
    });
  }

  void _emitMessages() {
    state = AsyncData(List.of(_messages));
  }

  // ---------------------------------------------------------------------------
  // Read / delivered sync
  // ---------------------------------------------------------------------------

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
        // Best-effort sync. Backend/realtime/next refresh can correct state.
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

    if (changed) {
      _emitMessages();
    }
  }

  // ---------------------------------------------------------------------------
  // Conversation sync
  // ---------------------------------------------------------------------------

  void _syncConversationPreview({
    required ChatMessage message,
    String? fallbackUser,
    String? fallbackDisplayName,
    String? fallbackAvatar,
  }) {
    ref
        .read(conversationsControllerProvider.notifier)
        .syncConversationWithMessage(
          conversationId: conversationId,
          message: message,
          fallbackUser: fallbackUser,
          fallbackDisplayName: fallbackDisplayName,
          fallbackAvatar: fallbackAvatar,
          incrementUnread: false,
        );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  List<String> _readMessageIds(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return [value.trim()];
    }

    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return const [];
  }

  bool _isSameTemp(ChatMessage temp, ChatMessage real) {
    if (!temp.id.startsWith('temp-')) return false;
    if (temp.sender != real.sender) return false;

    final sameText = temp.content == real.content;
    final sameReply = temp.replyToMessage == real.replyToMessage;
    final sameAttachments = temp.attachments.length == real.attachments.length;

    return sameText && sameReply && sameAttachments;
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

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
