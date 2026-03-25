class ChatAttachment {
  final String url;
  final String type;
  final int sortOrder;

  ChatAttachment({
    required this.url,
    required this.type,
    required this.sortOrder,
  });

  factory ChatAttachment.fromJson(Map<String, dynamic> json) {
    return ChatAttachment(
      url: json['url'] ?? '',
      type: json['type'] ?? '',
      sortOrder: json['sort_order'] ?? 0,
    );
  }
}
