import 'dart:io';

class ChatPendingAttachment {
  final File file;
  final String type;
  final bool deleteAfterUse;

  const ChatPendingAttachment({
    required this.file,
    required this.type,
    this.deleteAfterUse = false,
  });

  String get path => file.path;
}
