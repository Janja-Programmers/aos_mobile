import 'dart:io';

class ChatPendingAttachment {
  final File file;
  final String type;

  const ChatPendingAttachment({required this.file, required this.type});

  String get path => file.path;
}
