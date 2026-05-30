class PendingSendPayload {
  final String tempId;
  final String? text;
  final String? ad;
  final List<Map<String, dynamic>> attachments;

  final String? fallbackUser;
  final String? fallbackDisplayName;
  final String? fallbackAvatar;

  const PendingSendPayload({
    required this.tempId,
    this.text,
    this.ad,
    this.attachments = const [],
    this.fallbackUser,
    this.fallbackDisplayName,
    this.fallbackAvatar,
  });
}
