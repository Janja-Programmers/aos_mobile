class ChatAttachment {
  final String url;
  final String type;
  final int sortOrder;

  const ChatAttachment({
    required this.url,
    required this.type,
    required this.sortOrder,
  });

  factory ChatAttachment.fromJson(Map<String, dynamic> json) {
    return ChatAttachment(
      url: json['url']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      sortOrder: json['sort_order'] is int
          ? json['sort_order'] as int
          : int.tryParse(json['sort_order']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'type': type, 'sort_order': sortOrder};
  }

  ChatAttachment copyWith({String? url, String? type, int? sortOrder}) {
    return ChatAttachment(
      url: url ?? this.url,
      type: type ?? this.type,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  bool get isImage => type == 'image';
  bool get isAudio => type == 'audio';
  bool get isVideo => type == 'video';
  bool get isDocument => type == 'document';
}
