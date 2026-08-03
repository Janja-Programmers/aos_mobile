import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_attachment.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_local_message_status.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message_reaction.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message_viewer_state.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_reply_preview.dart';
import 'package:africaonlinestores/features/connect/chats/domain/payloads/chat_shared_payload.dart';

const Object _unset = Object();

class ChatMessage {
  final String id;
  final String senderCanonicalId;
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
  final String? callId;
  final String? callType;
  final String? callStatus;
  final String? callDirection;
  final int? callDurationSeconds;
  final bool isTranslating;
  final String? translationError;

  const ChatMessage({
    required this.id,
    required this.senderCanonicalId,
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
    this.callId,
    this.callType,
    this.callStatus,
    this.callDirection,
    this.callDurationSeconds,
    this.isTranslating = false,
    this.translationError,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final attachments =
        asJsonMapList(json['attachments']).map(ChatAttachment.fromJson).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final rawAdPreview = json['ad_preview'];
    final rawReplyTo = json['reply_to'];
    final rawViewerState = json['viewer_state'];

    final reactions = asJsonMapList(json['reactions'])
        .map(ChatMessageReaction.fromJson)
        .where((reaction) => reaction.emoji.trim().isNotEmpty)
        .toList();

    final normalizedType = normalizeMessageType(
      json['message_type']?.toString().trim().toLowerCase(),
    );

    return ChatMessage(
      id: json['id']?.toString() ?? '',
      senderCanonicalId: _normalizeSender(json['sender']),
      senderDisplayName: _cleanNullableString(json['sender_display_name']),
      senderAvatar: _cleanNullableString(json['sender_avatar']),
      content: _cleanNullableString(json['content']),
      messageType: normalizedType,
      originalMessageType: _cleanNullableString(json['original_message_type']),
      ad: _cleanNullableString(json['ad']),
      adPreview: rawAdPreview is Map ? asJsonMap(rawAdPreview) : null,
      replyToMessage: _cleanNullableString(json['reply_to_message']),
      replyTo: rawReplyTo is Map
          ? ChatReplyPreview.fromJson(asJsonMap(rawReplyTo))
          : null,
      hasAttachments:
          _truthy(json['has_attachments']) || attachments.isNotEmpty,
      createdAt: _parseDate(json['created_at']) ?? _invalidServerTimestamp,
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
          ? ChatMessageViewerState.fromJson(asJsonMap(rawViewerState))
          : const ChatMessageViewerState(),

      // Usually not present in normal message payloads.
      // Useful if you ever hydrate translated messages from cache/API.
      translatedContent: _cleanNullableString(json['translated_content']),
      translationLanguage: _cleanNullableString(
        json['target_language_label'] ??
            json['target_language'] ??
            json['translation_language'],
      ),
      callId: _cleanNullableString(json['call_id'] ?? json['call']),
      callType: _cleanNullableString(
        json['call_type'] ?? json['call_media_type'] ?? json['media_type'],
      ),
      callStatus: _cleanNullableString(
        json['call_status'] ?? json['call_state'] ?? json['status'],
      ),
      callDirection: _cleanNullableString(
        json['call_direction'] ?? json['direction'],
      ),
      callDurationSeconds: _parseInt(
        json['call_duration_seconds'] ??
            json['duration_seconds'] ??
            json['call_duration'] ??
            json['duration'],
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
      case 'call':
      case 'deleted':
      case 'location':
      case 'contact':
        return type!;
      default:
        return 'unknown';
    }
  }

  ChatMessage copyWith({
    String? id,
    String? senderCanonicalId,
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
    Object? callId = _unset,
    Object? callType = _unset,
    Object? callStatus = _unset,
    Object? callDirection = _unset,
    Object? callDurationSeconds = _unset,
    bool? isTranslating,
    String? translationError,
    bool clearTranslation = false,
    bool clearTranslationError = false,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderCanonicalId: senderCanonicalId ?? this.senderCanonicalId,
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
      callId: identical(callId, _unset) ? this.callId : callId as String?,
      callType: identical(callType, _unset)
          ? this.callType
          : callType as String?,
      callStatus: identical(callStatus, _unset)
          ? this.callStatus
          : callStatus as String?,
      callDirection: identical(callDirection, _unset)
          ? this.callDirection
          : callDirection as String?,
      callDurationSeconds: identical(callDurationSeconds, _unset)
          ? this.callDurationSeconds
          : callDurationSeconds as int?,
      isTranslating: isTranslating ?? this.isTranslating,
      translationError: clearTranslationError
          ? null
          : translationError ?? this.translationError,
    );
  }

  factory ChatMessage.temp({
    required String id,
    required String senderCanonicalId,
    String? senderDisplayName,
    String? senderAvatar,
    String? content,
    List<ChatAttachment> attachments = const [],
    String? ad,
    Map<String, dynamic>? adPreview,
    String? replyToMessage,
    ChatReplyPreview? replyTo,
    String? callId,
    String? callType,
    String? callStatus,
    String? callDirection,
    int? callDurationSeconds,
  }) {
    final cleanContent = content?.trim();
    final cleanAd = ad?.trim();

    final hasText = cleanContent != null && cleanContent.isNotEmpty;
    final hasFiles = attachments.isNotEmpty;
    final hasAd = cleanAd != null && cleanAd.isNotEmpty;

    final specialType = _specialPayloadType(cleanContent);
    final String messageType;
    if (specialType != null) {
      messageType = specialType;
    } else if (hasAd) {
      messageType = hasText || hasFiles ? 'mixed' : 'ad';
    } else if (hasText && hasFiles) {
      messageType = 'mixed';
    } else if (hasFiles) {
      messageType = 'media';
    } else {
      messageType = 'text';
    }

    return ChatMessage(
      id: id,
      senderCanonicalId: _normalizeSender(senderCanonicalId),
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
      attachments: attachments,
      localStatus: ChatLocalMessageStatus.sending,
      callId: callId,
      callType: callType,
      callStatus: callStatus,
      callDirection: callDirection,
      callDurationSeconds: callDurationSeconds,
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
      viewerState: const ChatMessageViewerState(),
      clearTranslation: true,
      clearTranslationError: true,
    );
  }

  bool get hasText => (content ?? '').trim().isNotEmpty;
  bool get hasAd => (ad ?? '').trim().isNotEmpty;
  bool get hasAdPreview => adPreview != null && adPreview!.isNotEmpty;
  bool get isTextOnly => messageType == 'text' && !hasAd && attachments.isEmpty;
  bool get isMixed => messageType == 'mixed';
  bool get isAd => messageType == 'ad';
  bool get isSystemType => messageType == 'system';
  bool get isCallType =>
      messageType == 'call' ||
      (callId ?? '').trim().isNotEmpty ||
      _looksLikeCallMessage(visibleText);
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

    final contact = ChatContactPayload.tryParse(content);
    if (contact != null) return '[Contact] ${contact.title}';

    final location = ChatLocationPayload.tryParse(content);
    if (location != null) return '[Location] ${location.title}';

    return content ?? '';
  }

  bool get isSystemMessage {
    return senderCanonicalId.trim().toLowerCase() == 'administrator' ||
        isSystemType ||
        isCallType;
  }

  bool get isGenericSystemMessage {
    return senderCanonicalId.trim().toLowerCase() == 'administrator' || isSystemType;
  }

  bool get isLocalSending => localStatus == ChatLocalMessageStatus.sending;
  bool get isLocalFailed => localStatus == ChatLocalMessageStatus.failed;
  bool get isLocalOnly => id.startsWith('temp-');
}

final DateTime _invalidServerTimestamp = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

String _normalizeSender(dynamic value) {
  final clean = value?.toString().trim() ?? '';
  if (clean.isEmpty || clean.toLowerCase() == 'null') return '';
  return clean.toUpperCase();
}

String? _specialPayloadType(String? value) {
  if (ChatLocationPayload.tryParse(value) != null) return 'location';
  if (ChatContactPayload.tryParse(value) != null) return 'contact';
  return null;
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

bool _looksLikeCallMessage(String value) {
  final text = value.trim().toLowerCase();
  if (text.isEmpty) return false;

  return text.contains('voice call') ||
      text.contains('video call') ||
      text.contains('missed call') ||
      text.contains('missed voice') ||
      text.contains('missed video') ||
      text.contains('no answer') ||
      text.contains('calling…') ||
      text.contains('calling...') ||
      text.contains('📞') ||
      text.contains('🎥');
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.round();

  final raw = value.toString().trim();
  if (raw.isEmpty) return null;

  final parsed = int.tryParse(raw);
  if (parsed != null) return parsed;

  final asDouble = double.tryParse(raw);
  return asDouble?.round();
}
