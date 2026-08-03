import 'dart:async';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/connect/chats/application/providers/chat_providers.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_attachment.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_identity.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_local_message_status.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message_merge.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message_reaction.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message_viewer_state.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_reply_preview.dart';
import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_input_controller.dart';
import 'package:africaonlinestores/features/connect/chats/domain/pending_send_payload.dart';
import 'package:africaonlinestores/features/connect/chats/repository/chat_repository_impl.dart';
import 'package:africaonlinestores/features/connect/conversations/application/providers/conversation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
part 'chat_messages_actions.dart';
part 'chat_messages_helpers.dart';
part 'chat_messages_lifecycle.dart';
part 'chat_messages_read_sync.dart';
part 'chat_messages_realtime.dart';
part 'chat_messages_sending.dart';
part 'chat_messages_state.dart';
part 'chat_messages_store.dart';
part 'chat_messages_translation.dart';

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
  final Set<String> _editingMessageIds = {};
  final Set<String> _starringMessageIds = {};
  final Set<String> _reactingMessageIds = {};
  final Set<String> _deletingMessageKeys = {};
  final Set<String> _forwardingMessageIds = {};
  final Map<String, String> _translationErrors = {};

  String? _activeSid;
  String _activeCanonicalAccountId = '';
  int _sessionGeneration = 0;

  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;

  StreamSubscription<Object?>? _messageSub;
  StreamSubscription<Object?>? _messageStatusSub;
  StreamSubscription<Object?>? _messageEditedSub;
  StreamSubscription<Object?>? _messagesDeletedSub;
  StreamSubscription<Object?>? _messageReactionSub;

  Timer? _readSyncDebounce;
  bool _isSyncingReadState = false;

  void _handleAuthChanged(AuthState? previous, AuthState next) {
    if (next is AuthAuthenticated) {
      final nextSid = next.sid.trim();
      final nextAccountId = normalizeCanonicalUserId(next.user.accountId);
      if (nextSid.isEmpty || nextAccountId.isEmpty) {
        _resetForUnauthenticatedState();
        return;
      }
      if (_activeSid == nextSid &&
          _activeCanonicalAccountId == nextAccountId) {
        return;
      }

      _activeSid = nextSid;
      _activeCanonicalAccountId = nextAccountId;
      final generation = ++_sessionGeneration;
      _clearAccountOwnedState(showLoading: true);
      unawaited(_initializeAuthenticatedSession(generation));
      return;
    }

    if (next is AuthGuest || next is AuthRestorationFailure) {
      _resetForUnauthenticatedState();
    }
  }

  void _resetForUnauthenticatedState() {
    _activeSid = null;
    _activeCanonicalAccountId = '';
    ++_sessionGeneration;
    _clearAccountOwnedState(showLoading: false);
    unawaited(_cancelRealtimeSubscriptions());
  }

  void _clearAccountOwnedState({required bool showLoading}) {
    _readSyncDebounce?.cancel();
    _readSyncDebounce = null;
    _isSyncingReadState = false;
    _isLoadingMore = false;
    _hasMoreMessages = true;
    _messages.clear();
    _pendingSends.clear();
    _translatingMessageIds.clear();
    _editingMessageIds.clear();
    _starringMessageIds.clear();
    _reactingMessageIds.clear();
    _deletingMessageKeys.clear();
    _forwardingMessageIds.clear();
    _translationErrors.clear();
    state = showLoading
        ? const ChatMessagesState.initial()
        : const ChatMessagesState(
            messages: [],
            isInitialLoading: false,
            isLoadingMore: false,
            hasMoreMessages: true,
          );
  }

  bool _isCurrentSession(int generation) {
    return mounted &&
        generation == _sessionGeneration &&
        _activeSid != null &&
        _activeCanonicalAccountId.isNotEmpty;
  }

  @override
  void dispose() {
    _readSyncDebounce?.cancel();
    unawaited(_messageSub?.cancel());
    unawaited(_messageStatusSub?.cancel());
    unawaited(_messageEditedSub?.cancel());
    unawaited(_messagesDeletedSub?.cancel());
    unawaited(_messageReactionSub?.cancel());
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Cross-part private API used by controller mixins.
  //
  // Dart private members are library-scoped, but a mixin can only call members
  // declared by its `on` constraint. These abstract declarations let the split
  // files call each other while keeping the implementation behavior in the
  // focused part files below.
  // ---------------------------------------------------------------------------

  Future<void> _listenRealtime();
  Future<void> _cancelRealtimeSubscriptions();
  Future<void> _initializeAuthenticatedSession(int generation);
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

  List<String> _readMessageIds(Object? value);
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
    ref.listen<AuthState>(
      authControllerProvider,
      _handleAuthChanged,
      fireImmediately: true,
    );
  }
}
