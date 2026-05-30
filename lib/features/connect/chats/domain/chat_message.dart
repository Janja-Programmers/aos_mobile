import 'package:africaonlinestores/features/connect/chats/domain/chat_attachment.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_local_message_status.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message_reaction.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message_viewer_state.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_reply_preview.dart';

const Object _unset = Object();

class ChatMessage {
  final String id;
  final String sender;
  final String? senderDisplayName;
  final String? senderAvatar;
  final String? content;
  final String messageType;
  final String? originalMessageType;
  final String? ad;
  final Map<String, dynamic>? adPreview;
  final String? replyToMessage;
  final ChatReplyPreview? replyTo;
  final bool hasAttachments;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final List<ChatAttachment> attachments;
  final List<ChatMessageReaction> reactions;
  final bool isForwarded;
  final String? forwardedFromMessage;
  final String? forwardedFromConversation;
  final bool isEdited;
  final DateTime? editedAt;
  final bool isDeletedForEveryone;
  final DateTime? deletedForEveryoneAt;
  final String? displayText;
  final ChatMessageViewerState viewerState;
  final ChatLocalMessageStatus localStatus;
  final String? localError;
  final String? translatedContent;
  final String? translationLanguage;

  const ChatMessage({
    required this.id,
    required this.sender,
    this.senderDisplayName,
    this.senderAvatar,
    this.content,
    required this.messageType,
    this.originalMessageType,
    this.ad,
    this.adPreview,
    this.replyToMessage,
    this.replyTo,
    required this.hasAttachments,
    required this.createdAt,
    this.deliveredAt,
    this.readAt,
    required this.attachments,
    this.reactions = const [],
    this.isForwarded = false,
    this.forwardedFromMessage,
    this.forwardedFromConversation,
    this.isEdited = false,
    this.editedAt,
    this.isDeletedForEveryone = false,
    this.deletedForEveryoneAt,
    this.displayText,
    this.viewerState = const ChatMessageViewerState(),
    this.localStatus = ChatLocalMessageStatus.none,
    this.localError,
    this.translatedContent,
    this.translationLanguage,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final attachments =
        (json['attachments'] as List? ?? [])
            .whereType<Map>()
            .map((e) => ChatAttachment.fromJson(Map<String, dynamic>.from(e)))
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final rawAdPreview = json['ad_preview'];
    final rawReplyTo = json['reply_to'];
    final rawViewerState = json['viewer_state'];

    final reactions = (json['reactions'] as List? ?? [])
        .whereType<Map>()
        .map((e) => ChatMessageReaction.fromJson(Map<String, dynamic>.from(e)))
        .where((reaction) => reaction.emoji.trim().isNotEmpty)
        .toList();

    final normalizedType = normalizeMessageType(
      json['message_type']?.toString().trim().toLowerCase(),
    );

    return ChatMessage(
      id: json['id']?.toString() ?? '',
      sender: json['sender']?.toString() ?? '',
      senderDisplayName: _cleanNullableString(json['sender_display_name']),
      senderAvatar: _cleanNullableString(json['sender_avatar']),
      content: _cleanNullableString(json['content']),
      messageType: normalizedType,
      originalMessageType: _cleanNullableString(json['original_message_type']),
      ad: _cleanNullableString(json['ad']),
      adPreview: rawAdPreview is Map
          ? Map<String, dynamic>.from(rawAdPreview)
          : null,
      replyToMessage: _cleanNullableString(json['reply_to_message']),
      replyTo: rawReplyTo is Map
          ? ChatReplyPreview.fromJson(Map<String, dynamic>.from(rawReplyTo))
          : null,
      hasAttachments:
          _truthy(json['has_attachments']) || attachments.isNotEmpty,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      deliveredAt: _parseDate(json['delivered_at']),
      readAt: _parseDate(json['read_at']),
      attachments: attachments,
      reactions: reactions,
      isForwarded: _truthy(json['is_forwarded']),
      forwardedFromMessage: _cleanNullableString(
        json['forwarded_from_message'],
      ),
      forwardedFromConversation: _cleanNullableString(
        json['forwarded_from_conversation'],
      ),
      isEdited: _truthy(json['is_edited']),
      editedAt: _parseDate(json['edited_at']),
      isDeletedForEveryone:
          _truthy(json['is_deleted_for_everyone']) ||
          normalizedType == 'deleted',
      deletedForEveryoneAt: _parseDate(json['deleted_for_everyone_at']),
      displayText: _cleanNullableString(json['display_text']),
      viewerState: rawViewerState is Map
          ? ChatMessageViewerState.fromJson(
              Map<String, dynamic>.from(rawViewerState),
            )
          : const ChatMessageViewerState(),
      localStatus: ChatLocalMessageStatus.none,
      localError: null,

      // Usually not present in normal message payloads.
      // Useful if you ever hydrate translated messages from cache/API.
      translatedContent: _cleanNullableString(json['translated_content']),
      translationLanguage: _cleanNullableString(
        json['target_language_label'] ??
            json['target_language'] ??
            json['translation_language'],
      ),
    );
  }

  static String normalizeMessageType(String? type) {
    switch (type) {
      case 'text':
      case 'media':
      case 'attachment':
      case 'mixed':
      case 'ad':
      case 'system':
      case 'deleted':
        return type!;
      default:
        return 'text';
    }
  }

  ChatMessage copyWith({
    String? id,
    String? sender,
    Object? senderDisplayName = _unset,
    Object? senderAvatar = _unset,
    Object? content = _unset,
    String? messageType,
    Object? originalMessageType = _unset,
    Object? ad = _unset,
    Object? adPreview = _unset,
    Object? replyToMessage = _unset,
    Object? replyTo = _unset,
    bool? hasAttachments,
    DateTime? createdAt,
    Object? deliveredAt = _unset,
    Object? readAt = _unset,
    List<ChatAttachment>? attachments,
    List<ChatMessageReaction>? reactions,
    bool? isForwarded,
    Object? forwardedFromMessage = _unset,
    Object? forwardedFromConversation = _unset,
    bool? isEdited,
    Object? editedAt = _unset,
    bool? isDeletedForEveryone,
    Object? deletedForEveryoneAt = _unset,
    Object? displayText = _unset,
    ChatMessageViewerState? viewerState,
    ChatLocalMessageStatus? localStatus,
    String? localError,
    bool clearLocalError = false,

    // Translation
    Object? translatedContent = _unset,
    Object? translationLanguage = _unset,
    bool clearTranslation = false,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      senderDisplayName: identical(senderDisplayName, _unset)
          ? this.senderDisplayName
          : senderDisplayName as String?,
      senderAvatar: identical(senderAvatar, _unset)
          ? this.senderAvatar
          : senderAvatar as String?,
      content: identical(content, _unset) ? this.content : content as String?,
      messageType: messageType ?? this.messageType,
      originalMessageType: identical(originalMessageType, _unset)
          ? this.originalMessageType
          : originalMessageType as String?,
      ad: identical(ad, _unset) ? this.ad : ad as String?,
      adPreview: identical(adPreview, _unset)
          ? this.adPreview
          : adPreview as Map<String, dynamic>?,
      replyToMessage: identical(replyToMessage, _unset)
          ? this.replyToMessage
          : replyToMessage as String?,
      replyTo: identical(replyTo, _unset)
          ? this.replyTo
          : replyTo as ChatReplyPreview?,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: identical(deliveredAt, _unset)
          ? this.deliveredAt
          : deliveredAt as DateTime?,
      readAt: identical(readAt, _unset) ? this.readAt : readAt as DateTime?,
      attachments: attachments ?? this.attachments,
      reactions: reactions ?? this.reactions,
      isForwarded: isForwarded ?? this.isForwarded,
      forwardedFromMessage: identical(forwardedFromMessage, _unset)
          ? this.forwardedFromMessage
          : forwardedFromMessage as String?,
      forwardedFromConversation: identical(forwardedFromConversation, _unset)
          ? this.forwardedFromConversation
          : forwardedFromConversation as String?,
      isEdited: isEdited ?? this.isEdited,
      editedAt: identical(editedAt, _unset)
          ? this.editedAt
          : editedAt as DateTime?,
      isDeletedForEveryone: isDeletedForEveryone ?? this.isDeletedForEveryone,
      deletedForEveryoneAt: identical(deletedForEveryoneAt, _unset)
          ? this.deletedForEveryoneAt
          : deletedForEveryoneAt as DateTime?,
      displayText: identical(displayText, _unset)
          ? this.displayText
          : displayText as String?,
      viewerState: viewerState ?? this.viewerState,
      localStatus: localStatus ?? this.localStatus,
      localError: clearLocalError ? null : localError ?? this.localError,
      translatedContent: clearTranslation
          ? null
          : identical(translatedContent, _unset)
          ? this.translatedContent
          : translatedContent as String?,
      translationLanguage: clearTranslation
          ? null
          : identical(translationLanguage, _unset)
          ? this.translationLanguage
          : translationLanguage as String?,
    );
  }

  factory ChatMessage.temp({
    required String id,
    required String sender,
    String? senderDisplayName,
    String? senderAvatar,
    String? content,
    List<ChatAttachment> attachments = const [],
    String? ad,
    Map<String, dynamic>? adPreview,
    String? replyToMessage,
    ChatReplyPreview? replyTo,
  }) {
    final cleanContent = content?.trim();
    final cleanAd = ad?.trim();

    final hasText = cleanContent != null && cleanContent.isNotEmpty;
    final hasFiles = attachments.isNotEmpty;
    final hasAd = cleanAd != null && cleanAd.isNotEmpty;

    final messageType = hasAd
        ? hasText || hasFiles
              ? 'mixed'
              : 'ad'
        : hasText && hasFiles
        ? 'mixed'
        : hasFiles
        ? 'media'
        : 'text';

    return ChatMessage(
      id: id,
      sender: sender,
      senderDisplayName: senderDisplayName,
      senderAvatar: senderAvatar,
      content: hasText ? cleanContent : null,
      messageType: messageType,
      ad: hasAd ? cleanAd : null,
      adPreview: adPreview,
      replyToMessage: replyToMessage,
      replyTo: replyTo,
      hasAttachments: hasFiles,
      createdAt: DateTime.now(),
      deliveredAt: null,
      readAt: null,
      attachments: attachments,
      localStatus: ChatLocalMessageStatus.sending,
      localError: null,
      translatedContent: null,
      translationLanguage: null,
    );
  }

  ChatMessage asDeletedPlaceholder({String? displayText}) {
    return copyWith(
      content: null,
      messageType: 'deleted',
      ad: null,
      adPreview: null,
      hasAttachments: false,
      attachments: const [],
      reactions: const [],
      isDeletedForEveryone: true,
      deletedForEveryoneAt: DateTime.now(),
      displayText: displayText ?? 'This message was deleted',
      viewerState: viewerState.copyWith(myReaction: null),
      clearTranslation: true,
    );
  }

  bool get hasText => (content ?? '').trim().isNotEmpty;
  bool get hasAd => (ad ?? '').trim().isNotEmpty;
  bool get hasAdPreview => adPreview != null && adPreview!.isNotEmpty;
  bool get isTextOnly => messageType == 'text' && !hasAd && attachments.isEmpty;
  bool get isMixed => messageType == 'mixed';
  bool get isAd => messageType == 'ad';
  bool get isSystemType => messageType == 'system';
  bool get isDeletedType => messageType == 'deleted' || isDeletedForEveryone;
  bool get hasOnlyAttachments => !hasText && !hasAd && attachments.isNotEmpty;

  bool get isAttachmentOnly =>
      messageType == 'attachment' ||
      messageType == 'media' ||
      hasOnlyAttachments;

  bool get isStarred => viewerState.isStarred;
  String? get myReaction => viewerState.myReaction;

  bool get hasTranslation => (translatedContent ?? '').trim().isNotEmpty;

  String get translatedText => translatedContent ?? '';

  String get visibleText {
    if (isDeletedType) return displayText ?? 'This message was deleted';
    return content ?? '';
  }

  bool get isSystemMessage {
    return sender.trim().toLowerCase() == 'administrator' || isSystemType;
  }

  bool get isLocalSending => localStatus == ChatLocalMessageStatus.sending;
  bool get isLocalFailed => localStatus == ChatLocalMessageStatus.failed;
  bool get isLocalOnly => id.startsWith('temp-');
}

bool _truthy(dynamic value) {
  if (value == null) return false;
  if (value == true) return true;
  if (value == false) return false;
  if (value is num) return value != 0;

  final text = value.toString().trim().toLowerCase();
  return text == '1' || text == 'true' || text == 'yes';
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;

  final text = value.toString().trim();

  if (text.isEmpty || text.toLowerCase() == 'null') return null;

  return DateTime.tryParse(text);
}

String? _cleanNullableString(dynamic value) {
  if (value == null) return null;

  final text = value.toString().trim();

  if (text.isEmpty || text.toLowerCase() == 'null') return null;

  return text;
}
