import 'package:africaonlinestores/features/connect/chats/domain/chat_reply_preview.dart';

class PendingSendPayload {
  final String tempId;
  final String? text;
  final String? ad;
  final String? replyToMessage;
  final ChatReplyPreview? replyTo;
  final List<Map<String, dynamic>> attachments;

  final String? fallbackUser;
  final String? fallbackDisplayName;
  final String? fallbackAvatar;

  const PendingSendPayload({
    required this.tempId,
    this.text,
    this.ad,
    this.replyToMessage,
    this.replyTo,
    this.attachments = const [],
    this.fallbackUser,
    this.fallbackDisplayName,
    this.fallbackAvatar,
  });
}
