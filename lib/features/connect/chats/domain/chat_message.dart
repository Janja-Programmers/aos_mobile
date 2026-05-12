import 'package:africaonlinestores/features/connect/chats/domain/chat_attachment.dart';

class ChatMessage {
  final String id;
  final String sender;
  final String? content;
  final String messageType;
  final String? ad;
  final bool hasAttachments;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final List<ChatAttachment> attachments;

  const ChatMessage({
    required this.id,
    required this.sender,
    this.content,
    required this.messageType,
    this.ad,
    required this.hasAttachments,
    required this.createdAt,
    this.deliveredAt,
    this.readAt,
    required this.attachments,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final attachments =
        (json['attachments'] as List? ?? [])
            .map((e) => ChatAttachment.fromJson(Map<String, dynamic>.from(e)))
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final type = json['message_type']?.toString() ?? 'text';

    final normalizedType = (type == 'mixed' || type == 'attachment')
        ? type
        : 'text';

    return ChatMessage(
      id: json['id']?.toString() ?? '',
      sender: json['sender']?.toString() ?? '',
      content: json['content']?.toString(),
      messageType: normalizedType,
      ad: json['ad']?.toString(),
      hasAttachments:
          json['has_attachments'] == 1 || json['has_attachments'] == true,
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

  ChatMessage copyWith({
    String? id,
    String? sender,
    String? content,
    String? messageType,
    String? ad,
    bool? hasAttachments,
    DateTime? createdAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    List<ChatAttachment>? attachments,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      ad: ad ?? this.ad,
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
    String? content,
    List<ChatAttachment> attachments = const [],
    String? ad,
  }) {
    final hasText = content?.trim().isNotEmpty == true;
    final hasFiles = attachments.isNotEmpty;

    return ChatMessage(
      id: id,
      sender: sender,
      content: hasText ? content!.trim() : null,
      messageType: hasText && hasFiles
          ? 'mixed'
          : hasFiles
          ? 'attachment'
          : 'text',
      ad: ad,
      hasAttachments: hasFiles,
      createdAt: DateTime.now(),
      deliveredAt: null,
      readAt: null,
      attachments: attachments,
    );
  }

  bool get hasText => (content ?? '').trim().isNotEmpty;
  bool get isTextOnly => messageType == 'text' && attachments.isEmpty;
  bool get isMixed => messageType == 'mixed';
  bool get hasOnlyAttachments => !hasText && attachments.isNotEmpty;
  bool get isSystemMessage {
    return sender.trim().toLowerCase() == 'administrator';
  }
}
