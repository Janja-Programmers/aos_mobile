import 'package:flutter/foundation.dart';

enum LiveReactionType {
  like('like', '❤️', 'Like'),
  fire('fire', '🔥', 'Fire'),
  clap('clap', '👏', 'Clap'),
  love('love', '🥰', 'Love'),
  wow('wow', '😮', 'Wow');

  const LiveReactionType(this.apiValue, this.emoji, this.label);

  final String apiValue;
  final String emoji;
  final String label;

  static LiveReactionType? fromApiValue(Object? value) {
    final normalized = value?.toString().trim().toLowerCase();
    for (final reaction in values) {
      if (reaction.apiValue == normalized) return reaction;
    }
    return null;
  }
}

@immutable
class LiveReaction {
  const LiveReaction({
    required this.id,
    required this.liveId,
    required this.type,
    required this.createdAt,
  });

  factory LiveReaction.fromJson(Map<String, dynamic> json) {
    final type = LiveReactionType.fromApiValue(
      json['reaction_type'] ?? json['type'],
    );

    if (type == null) {
      throw const FormatException('Unsupported Live reaction type.');
    }

    return LiveReaction(
      id: json['reaction_id']?.toString() ?? json['id']?.toString() ?? '',
      liveId: json['live_id']?.toString() ?? '',
      type: type,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  final String id;
  final String liveId;
  final LiveReactionType type;
  final DateTime? createdAt;
}
