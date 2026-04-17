class NotificationPayload {
  final String? conversationId;
  final String? callId;
  final String? liveId;
  final String? adId;
  final String? userId;
  final String? route;
  final Map<String, dynamic>? extra;

  const NotificationPayload({
    this.conversationId,
    this.callId,
    this.liveId,
    this.adId,
    this.userId,
    this.route,
    this.extra,
  });

  factory NotificationPayload.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NotificationPayload();

    return NotificationPayload(
      conversationId: json['conversation_id']?.toString(),
      callId: json['call_id']?.toString(),
      liveId: json['live_id']?.toString(),
      adId: json['ad_id']?.toString(),
      userId: json['user_id']?.toString(),
      route: json['route'],
      extra: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'call_id': callId,
      'live_id': liveId,
      'ad_id': adId,
      'user_id': userId,
      'route': route,
      ...?extra,
    };
  }
}
