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
import 'package:africaonlinestores/features/connect/conversations/application/providers/conversation_provider.dart';

part 'chat_messages_state.dart';
part 'chat_messages_lifecycle.dart';
part 'chat_messages_sending.dart';
part 'chat_messages_actions.dart';
part 'chat_messages_translation.dart';
part 'chat_messages_realtime.dart';
part 'chat_messages_store.dart';
part 'chat_messages_read_sync.dart';
part 'chat_messages_helpers.dart';

abstract class ChatMessagesControllerBase
    extends StateNotifier<ChatMessagesState> {
  final Ref ref;
  final String conversationId;

  ChatMessagesControllerBase(this.ref, this.conversationId)
    : super(const ChatMessagesState.initial());

  // ---------------------------------------------------------------------------
  // Local state
  // ---------------------------------------------------------------------------

  final List<ChatMessage> _messages = [];
  final Map<String, PendingSendPayload> _pendingSends = {};

  final Set<String> _translatingMessageIds = {};
  final Map<String, String> _translationErrors = {};

  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;

  StreamSubscription? _messageSub;
  StreamSubscription? _messageStatusSub;
  StreamSubscription? _messageEditedSub;
  StreamSubscription? _messagesDeletedSub;
  StreamSubscription? _messageReactionSub;

  Timer? _readSyncDebounce;
  bool _isSyncingReadState = false;

  // ---------------------------------------------------------------------------
  // Cross-part private API used by controller mixins.
  //
  // Dart private members are library-scoped, but a mixin can only call members
  // declared by its `on` constraint. These abstract declarations let the split
  // files call each other while keeping the implementation behavior in the
  // focused part files below.
  // ---------------------------------------------------------------------------

  Future<void> _listenRealtime();
  Future<void> _syncIncomingReadState();

  void _replaceWithServerMessages(List<ChatMessage> serverMessages);
  void _appendOlderServerMessages(List<ChatMessage> olderMessages);
  void _upsertMessage(ChatMessage message);
  void _removeMessages(List<String> messageIds);
  void _markMessagesDeletedForEveryone(
    List<String> messageIds, {
    String? displayText,
  });
  void _emitMessages();

  bool _isIncomingMessage(ChatMessage message);
  void _scheduleIncomingReadSync();

  List<String> _readMessageIds(dynamic value);
  bool _isSameTemp(ChatMessage temp, ChatMessage real);
  void _applyEditedMessage(ChatMessage updated);
  void _applyReactionPayload(Map<String, dynamic> data);

  void _syncConversationPreview({
    required ChatMessage message,
    String? fallbackUser,
    String? fallbackDisplayName,
    String? fallbackAvatar,
  });
}

class ChatMessagesController extends ChatMessagesControllerBase
    with
        ChatMessagesLifecycle,
        ChatMessagesSending,
        ChatMessagesActions,
        ChatMessagesTranslation,
        ChatMessagesRealtime,
        ChatMessagesStore,
        ChatMessagesReadSync,
        ChatMessagesHelpers {
  ChatMessagesController(super.ref, super.conversationId) {
    _init();
  }
}
