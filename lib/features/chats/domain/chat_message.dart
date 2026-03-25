import 'package:africaonlinestores/features/chats/domain/chat_attachment.dart';

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

  ChatMessage({
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
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      sender: json['sender']?.toString() ?? '',
      content: json['content']?.toString(),
      messageType: json['message_type']?.toString() ?? 'text',
      ad: json['ad']?.toString(),
      hasAttachments:
          (json['has_attachments'] == 1 || json['has_attachments'] == true),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(json['delivered_at'].toString())
          : null,
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'].toString())
          : null,
      attachments: (json['attachments'] as List? ?? [])
          .map((e) => ChatAttachment.fromJson(e))
          .toList(),
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
}
