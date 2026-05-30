import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';

class ChatReplyPreview {
  final String id;
  final String sender;
  final String? senderDisplayName;
  final String? senderAvatar;
  final String? content;
  final String messageType;
  final String? originalMessageType;
  final String? ad;
  final Map<String, dynamic>? adPreview;
  final bool hasAttachments;
  final bool isForwarded;
  final bool isEdited;
  final DateTime? editedAt;
  final bool isDeletedForEveryone;
  final DateTime? deletedForEveryoneAt;
  final String? displayText;
  final DateTime? createdAt;

  const ChatReplyPreview({
    required this.id,
    required this.sender,
    this.senderDisplayName,
    this.senderAvatar,
    this.content,
    required this.messageType,
    this.originalMessageType,
    this.ad,
    this.adPreview,
    this.hasAttachments = false,
    this.isForwarded = false,
    this.isEdited = false,
    this.editedAt,
    this.isDeletedForEveryone = false,
    this.deletedForEveryoneAt,
    this.displayText,
    this.createdAt,
  });

  factory ChatReplyPreview.fromJson(Map<String, dynamic> json) {
    final rawAdPreview = json['ad_preview'];

    return ChatReplyPreview(
      id: json['id']?.toString() ?? '',
      sender: json['sender']?.toString() ?? '',
      senderDisplayName: _cleanNullableString(json['sender_display_name']),
      senderAvatar: _cleanNullableString(json['sender_avatar']),
      content: _cleanNullableString(json['content']),
      messageType: ChatMessage.normalizeMessageType(
        json['message_type']?.toString().trim().toLowerCase(),
      ),
      originalMessageType: _cleanNullableString(json['original_message_type']),
      ad: _cleanNullableString(json['ad']),
      adPreview: rawAdPreview is Map
          ? Map<String, dynamic>.from(rawAdPreview)
          : null,
      hasAttachments: _truthy(json['has_attachments']),
      isForwarded: _truthy(json['is_forwarded']),
      isEdited: _truthy(json['is_edited']),
      editedAt: _parseDate(json['edited_at']),
      isDeletedForEveryone: _truthy(json['is_deleted_for_everyone']),
      deletedForEveryoneAt: _parseDate(json['deleted_for_everyone_at']),
      displayText: _cleanNullableString(json['display_text']),
      createdAt: _parseDate(json['created_at']),
    );
  }

  bool get hasText => (content ?? '').trim().isNotEmpty;
  bool get hasAd => (ad ?? '').trim().isNotEmpty;
  bool get hasAdPreview => adPreview != null && adPreview!.isNotEmpty;
  bool get isDeleted => isDeletedForEveryone || messageType == 'deleted';

  String get previewText {
    if (isDeleted) return displayText ?? 'This message was deleted';
    if (hasText) return content!.trim();
    if (hasAdPreview) {
      final title =
          adPreview?['title'] ?? adPreview?['ad_title'] ?? adPreview?['name'];
      if (title != null && title.toString().trim().isNotEmpty) {
        return title.toString().trim();
      }
    }
    if (hasAd) return '[Ad]';
    if (hasAttachments) return '[Attachment]';
    return '[Message]';
  }
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
