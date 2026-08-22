class ChatOutgoingAttachment {
  final String file;
  final String fileType;
  final String ad;

  const ChatOutgoingAttachment({
    required this.file,
    required this.fileType,
    required this.ad,
  });

  Map<String, dynamic> toJson() {
    return {'file': file, 'file_type': fileType, 'ad': ad};
  }

  ChatOutgoingAttachment copyWith({
    String? file,
    String? fileType,
    String? ad,
  }) {
    return ChatOutgoingAttachment(
      file: file ?? this.file,
      fileType: fileType ?? this.fileType,
      ad: ad ?? this.ad,
    );
  }

  bool get isImage => fileType == 'image';
  bool get isAudio =>
      fileType == 'audio' ||
      fileType == 'voice' ||
      fileType == 'voice_note';
  bool get isVideo => fileType == 'video';
  bool get isDocument => fileType == 'document';
}
