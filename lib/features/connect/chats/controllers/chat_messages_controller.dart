import 'dart:async';

import 'package:africaonlinestores/features/connect/chats/domain/chat_attachment.dart';
import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_input_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/connect/chats/controllers/chat_service_providers.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/repository/chat_repository_impl.dart';

final chatMessagesControllerProvider =
    StateNotifierProvider.family<
      ChatMessagesController,
      AsyncValue<List<ChatMessage>>,
      String
    >((ref, conversationId) {
      return ChatMessagesController(ref, conversationId);
    });

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

    await repo.markRead(conversationId);
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
  Future<void> sendTempMessage({
    String? text,
    String? adId,
    String? adTitle,
    String? adPrice,
    String? adImage,
    List<ChatInputAttachment> attachments = const [],
  }) async {
    final trimmedText = text?.trim();

    final hasText = trimmedText != null && trimmedText.isNotEmpty;
    final hasAttachments = attachments.isNotEmpty;
    final hasAd = adId != null && adId.trim().isNotEmpty;

    if (!hasText && !hasAttachments && !hasAd) return;

    final tempId = 'temp-${DateTime.now().millisecondsSinceEpoch}';

    final apiAttachments = attachments
        .map((a) => a.toApi(ad: adId ?? ''))
        .toList();

    /// Add ad-only payload when there are no normal attachments.
    if (hasAd && apiAttachments.isEmpty) {
      apiAttachments.add({'ad': adId, 'file': '', 'file_type': 'ad'});
    }

    final tempMsg = ChatMessage(
      id: tempId,
      sender: currentUser,
      content: hasText ? trimmedText : null,
      messageType: hasAd
          ? hasText || hasAttachments
                ? 'mixed'
                : 'ad'
          : hasText && hasAttachments
          ? 'mixed'
          : hasAttachments
          ? 'attachment'
          : 'text',
      ad: hasAd ? adId : null,
      hasAttachments: hasAttachments || hasAd,
      createdAt: DateTime.now(),
      deliveredAt: null,
      readAt: null,
      attachments: attachments
          .map(
            (a) =>
                ChatAttachment(url: a.previewUrl, type: a.type, sortOrder: 0),
          )
          .toList(),
    );

    _messages.add(tempMsg);
    state = AsyncData(List.of(_messages));

    final realMsg = await sendMessage(
      text: trimmedText,
      ad: hasAd ? adId : null,
      attachments: apiAttachments,
    );

    if (realMsg == null) {
      _messages.removeWhere((m) => m.id == tempId);
      state = AsyncData(List.of(_messages));
    }
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

    final apiAttachments = List<Map<String, dynamic>>.from(attachments);

    if (hasAd && apiAttachments.isEmpty) {
      apiAttachments.add({'ad': ad, 'file': '', 'file_type': 'ad'});
    }

    final res = await repo.sendMessage(
      conversationId: conversationId,
      content: hasText ? trimmedText : null,
      attachments: apiAttachments,
    );

    if (res.isLeft) return null;

    return ChatMessage(
      id: 'server-${DateTime.now().millisecondsSinceEpoch}',
      sender: currentUser,
      content: hasText ? trimmedText : null,
      messageType: hasAd
          ? hasText || hasAttachments
                ? 'mixed'
                : 'ad'
          : hasText && hasAttachments
          ? 'mixed'
          : hasAttachments
          ? 'attachment'
          : 'text',
      ad: hasAd ? ad : null,
      hasAttachments: hasAttachments || hasAd,
      createdAt: DateTime.now(),
      deliveredAt: DateTime.now(),
      readAt: null,
      attachments: const [],
    );
  }

  // -----------------------------
  // Realtime Listener
  // -----------------------------
  Future<void> _listenRealtime() async {
    final realtime = ref.read(chatRealtimeServiceProvider);
    final repo = ref.read(chatRepositoryProvider);

    await _messageSub?.cancel();

    _messageSub = realtime.messages.listen((data) async {
      final convId = data['conversation_id'];
      if (convId != conversationId) return;

      final msgData = data['message'];
      if (msgData == null) return;

      final newMsg = ChatMessage.fromJson(msgData);

      _messages.removeWhere((m) => _isSameTemp(m, newMsg));

      if (_isDuplicate(newMsg)) return;

      _messages.add(newMsg);
      state = AsyncData(List.of(_messages));

      await repo.markDelivered(conversationId);
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
    super.dispose();
  }
}
