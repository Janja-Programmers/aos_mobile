class ChatInputAttachment {
  final String fileId;
  final String type;
  final String previewUrl;

  const ChatInputAttachment({
    required this.fileId,
    required this.type,
    required this.previewUrl,
  });

  Map<String, dynamic> toApi() {
    return {'file': fileId.trim(), 'file_type': type.trim()};
  }

  ChatInputAttachment copyWith({
    String? fileId,
    String? type,
    String? previewUrl,
  }) {
    return ChatInputAttachment(
      fileId: fileId ?? this.fileId,
      type: type ?? this.type,
      previewUrl: previewUrl ?? this.previewUrl,
    );
  }

  bool get isImage => type == 'image';
  bool get isAudio => type == 'audio';
  bool get isVideo => type == 'video';
  bool get isDocument => type == 'document';
}
