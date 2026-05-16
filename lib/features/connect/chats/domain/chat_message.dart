import 'package:africaonlinestores/features/connect/chats/domain/chat_attachment.dart';

class ChatMessage {
  final String id;
  final String sender;
  final String? senderDisplayName;
  final String? senderAvatar;
  final String? content;
  final String messageType;
  final String? ad;
  final Map<String, dynamic>? adPreview;
  final bool hasAttachments;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final List<ChatAttachment> attachments;

  const ChatMessage({
    required this.id,
    required this.sender,
    this.senderDisplayName,
    this.senderAvatar,
    this.content,
    required this.messageType,
    this.ad,
    this.adPreview,
    required this.hasAttachments,
    required this.createdAt,
    this.deliveredAt,
    this.readAt,
    required this.attachments,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final attachments =
        (json['attachments'] as List? ?? [])
            .whereType<Map>()
            .map((e) => ChatAttachment.fromJson(Map<String, dynamic>.from(e)))
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final rawType = json['message_type']?.toString().trim().toLowerCase();
    final normalizedType = _normalizeMessageType(rawType);

    final rawAdPreview = json['ad_preview'];
    final parsedAdPreview = rawAdPreview is Map
        ? Map<String, dynamic>.from(rawAdPreview)
        : null;

    return ChatMessage(
      id: json['id']?.toString() ?? '',
      sender: json['sender']?.toString() ?? '',
      senderDisplayName: json['sender_display_name']?.toString(),
      senderAvatar: json['sender_avatar']?.toString(),
      content: _cleanNullableString(json['content']),
      messageType: normalizedType,
      ad: _cleanNullableString(json['ad']),
      adPreview: parsedAdPreview,
      hasAttachments:
          json['has_attachments'] == 1 ||
          json['has_attachments'] == true ||
          attachments.isNotEmpty,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(json['delivered_at'].toString())
          : null,
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'].toString())
          : null,
      attachments: attachments,
    );
  }

  static String _normalizeMessageType(String? type) {
    switch (type) {
      case 'text':
      case 'attachment':
      case 'mixed':
      case 'ad':
      case 'system':
        return type!;
      default:
        return 'text';
    }
  }

  static String? _cleanNullableString(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;

    return text;
  }

  ChatMessage copyWith({
    String? id,
    String? sender,
    String? senderDisplayName,
    String? senderAvatar,
    String? content,
    String? messageType,
    String? ad,
    Map<String, dynamic>? adPreview,
    bool? hasAttachments,
    DateTime? createdAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    List<ChatAttachment>? attachments,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      senderDisplayName: senderDisplayName ?? this.senderDisplayName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      ad: ad ?? this.ad,
      adPreview: adPreview ?? this.adPreview,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      attachments: attachments ?? this.attachments,
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
        ? 'attachment'
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
      hasAttachments: hasFiles,
      createdAt: DateTime.now(),
      deliveredAt: null,
      readAt: null,
      attachments: attachments,
    );
  }

  bool get hasText => (content ?? '').trim().isNotEmpty;
  bool get hasAd => (ad ?? '').trim().isNotEmpty;
  bool get hasAdPreview => adPreview != null && adPreview!.isNotEmpty;
  bool get isTextOnly {
    return messageType == 'text' && !hasAd && attachments.isEmpty;
  }

  bool get isMixed => messageType == 'mixed';
  bool get isAd => messageType == 'ad';
  bool get isSystemType => messageType == 'system';
  bool get hasOnlyAttachments {
    return !hasText && !hasAd && attachments.isNotEmpty;
  }

  bool get isAttachmentOnly {
    return messageType == 'attachment' || hasOnlyAttachments;
  }

  bool get isSystemMessage {
    return sender.trim().toLowerCase() == 'administrator' || isSystemType;
  }
}
