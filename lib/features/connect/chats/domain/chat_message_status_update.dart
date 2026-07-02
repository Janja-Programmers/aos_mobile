import 'package:africaonlinestores/core/utils/json_utils.dart';

class ChatMessageStatusUpdate {
  final int updatedCount;
  final List<String> messageIds;
  final DateTime? deliveredAt;
  final DateTime? readAt;

  const ChatMessageStatusUpdate({
    required this.updatedCount,
    required this.messageIds,
    this.deliveredAt,
    this.readAt,
  });

  const ChatMessageStatusUpdate.empty()
    : updatedCount = 0,
      messageIds = const [],
      deliveredAt = null,
      readAt = null;

  factory ChatMessageStatusUpdate.fromJson(Map<String, dynamic> json) {
    final rawIds = json['message_ids'];
    final ids = asJsonList(rawIds)
        .map((value) => value.toString().trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);

    return ChatMessageStatusUpdate(
      updatedCount: _parseInt(json['updated_count']) ?? ids.length,
      messageIds: ids,
      deliveredAt: _parseDate(json['delivered_at']),
      readAt: _parseDate(json['read_at']),
    );
  }

  bool get hasUpdates => updatedCount > 0 && messageIds.isNotEmpty;
}

int? _parseInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;

  final raw = value.toString().trim();
  if (raw.isEmpty || raw.toLowerCase() == 'null') return null;

  return DateTime.tryParse(raw);
}
