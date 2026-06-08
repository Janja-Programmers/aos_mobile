part of 'chat_messages_controller.dart';

class ChatMessagesState {
  final List<ChatMessage> messages;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasMoreMessages;

  final Object? error;
  final StackTrace? stackTrace;
  final Object? actionError;
  final StackTrace? actionStackTrace;

  const ChatMessagesState({
    required this.messages,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.hasMoreMessages,
    this.error,
    this.stackTrace,
    this.actionError,
    this.actionStackTrace,
  });

  const ChatMessagesState.initial()
    : messages = const [],
      isInitialLoading = true,
      isLoadingMore = false,
      hasMoreMessages = true,
      error = null,
      stackTrace = null,
      actionError = null,
      actionStackTrace = null;

  bool get hasError => error != null;
  bool get hasActionError => actionError != null;
  bool get isEmpty => messages.isEmpty;

  ChatMessagesState copyWith({
    List<ChatMessage>? messages,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? hasMoreMessages,
    Object? error,
    StackTrace? stackTrace,
    Object? actionError,
    StackTrace? actionStackTrace,
    bool clearError = false,
    bool clearActionError = false,
  }) {
    return ChatMessagesState(
      messages: messages ?? this.messages,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      error: clearError ? null : error ?? this.error,
      stackTrace: clearError ? null : stackTrace ?? this.stackTrace,
      actionError: clearActionError ? null : actionError ?? this.actionError,
      actionStackTrace: clearActionError
          ? null
          : actionStackTrace ?? this.actionStackTrace,
    );
  }

  ChatMessagesState asLoading() {
    return copyWith(
      isInitialLoading: true,
      clearError: true,
      clearActionError: true,
    );
  }

  ChatMessagesState asData(List<ChatMessage> nextMessages) {
    return copyWith(
      messages: List.unmodifiable(nextMessages),
      isInitialLoading: false,
      clearError: true,
    );
  }

  ChatMessagesState asError(Object error, StackTrace stackTrace) {
    return copyWith(
      isInitialLoading: false,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
