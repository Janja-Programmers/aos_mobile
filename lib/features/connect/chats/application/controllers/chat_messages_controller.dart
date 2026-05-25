import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';

import 'package:africaonlinestores/features/connect/chats/application/providers/chat_providers.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_attachment.dart';
import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_input_controller.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/repository/chat_repository_impl.dart';

class ChatMessagesController
    extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final Ref ref;
  final String conversationId;
  late final String currentUser;

  ChatMessagesController(this.ref, this.conversationId)
    : super(const AsyncLoading()) {
    currentUser = ref.read(currentUserProvider) ?? "";

    _init();
  }

  final List<ChatMessage> _messages = [];
  StreamSubscription? _messageSub;
  StreamSubscription? _messageStatusSub;

  Future<void> _init() async {
    await loadInitial();
    await _listenRealtime();
  }

  // -----------------------------
  // Initial Load
  // -----------------------------
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

    final markReadRes = await repo.markRead(conversationId);

    if (markReadRes.isRight) {
      ref
          .read(chatConversationsControllerProvider.notifier)
          .markConversationAsReadLocally(conversationId);
    }
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

      if (status == 'delivered') {
        if (message.deliveredAt != null) continue;

        _messages[i] = message.copyWith(
          deliveredAt: deliveredAt ?? DateTime.now(),
        );
        changed = true;
      }

      if (status == 'read') {
        if (message.readAt != null) continue;

        final effectiveReadAt = readAt ?? DateTime.now();

        _messages[i] = message.copyWith(
          deliveredAt: message.deliveredAt ?? effectiveReadAt,
          readAt: effectiveReadAt,
        );
        changed = true;
      }
    }

    if (changed) {
      state = AsyncData(List.of(_messages));
    }
  }

  // -----------------------------
  // Pagination
  // -----------------------------
  Future<void> loadMore() async {
    if (_messages.isEmpty) return;

    final repo = ref.read(chatRepositoryProvider);
    final oldest = _messages.first;

    final res = await repo.getMessages(
      conversationId: conversationId,
      before: oldest.id,
    );

    if (res.isLeft) return;

    _messages.insertAll(0, res.rightOrNull!.reversed);
    state = AsyncData(List.of(_messages));
  }

  // -----------------------------
  // Optimistic Send
  // -----------------------------
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
    );

    _messages.add(tempMessage);
    state = AsyncData(List.of(_messages));

    final realMsg = await sendMessage(
      text: trimmedText,
      ad: hasAd ? adId : null,
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
    } else {
      _messages.add(realMsg);
    }

    state = AsyncData(List.of(_messages));

    ref
        .read(chatConversationsControllerProvider.notifier)
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

  // -----------------------------
  // Send Message
  // -----------------------------

  Future<ChatMessage?> sendMessage({
    String? text,
    String? ad,
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
      attachments: List<Map<String, dynamic>>.from(attachments),
    );
    if (res.isLeft) return null;

    return res.rightOrNull!;
  }

  // -----------------------------
  // Realtime Listener
  // -----------------------------
  Future<void> _listenRealtime() async {
    final realtime = ref.read(chatRealtimeServiceProvider);
    final repo = ref.read(chatRepositoryProvider);

    await _messageSub?.cancel();
    await _messageStatusSub?.cancel();

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

      // Only mark delivered for incoming messages.
      if (newMsg.sender.trim().toLowerCase() !=
          currentUser.trim().toLowerCase()) {
        await repo.markDelivered(conversationId);
      }
    });

    _messageStatusSub = realtime.messageStatus.listen((data) {
      final convId = data['conversation_id'];
      if (convId != conversationId) return;

      _applyMessageStatus(Map<String, dynamic>.from(data));
    });
  }

  bool _isDuplicate(ChatMessage newMsg) {
    return _messages.any((m) => m.id == newMsg.id);
  }

  bool _isSameTemp(ChatMessage temp, ChatMessage real) {
    if (!temp.id.startsWith('temp-')) return false;
    if (temp.sender != real.sender) return false;

    // Text match
    final sameText = temp.content == real.content;

    // Attachment match (count-based, simple but effective)
    final sameAttachments = temp.attachments.length == real.attachments.length;

    return sameText && sameAttachments;
  }

  // -----------------------------
  // Dispose
  // -----------------------------
  @override
  void dispose() {
    _messageSub?.cancel();
    _messageStatusSub?.cancel();
    super.dispose();
  }
}
