class ChatMessageReaction {
  final String emoji;
  final int count;
  final bool reactedByMe;

  const ChatMessageReaction({
    required this.emoji,
    required this.count,
    required this.reactedByMe,
  });

  factory ChatMessageReaction.fromJson(Map<String, dynamic> json) {
    return ChatMessageReaction(
      emoji: json['emoji']?.toString() ?? '',
      count: _cleanInt(json['count'] ?? json['reaction_count']),
      reactedByMe: _truthy(json['reacted_by_me']),
    );
  }
}

bool _truthy(dynamic value) {
  if (value == null) return false;
  if (value == true) return true;
  if (value == false) return false;
  if (value is num) return value != 0;

  final text = value.toString().trim().toLowerCase();
  return text == '1' || text == 'true' || text == 'yes';
}

int _cleanInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
