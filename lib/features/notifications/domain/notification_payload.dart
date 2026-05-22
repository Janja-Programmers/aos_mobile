class NotificationPayload {
  final String? conversationId;
  final String? callId;
  final String? liveId;
  final String? adId;
  final String? shortId;
  final String? commentId;
  final String? userId;
  final String? route;
  final String? event;
  final Map<String, dynamic> extra;

  const NotificationPayload({
    this.conversationId,
    this.callId,
    this.liveId,
    this.adId,
    this.shortId,
    this.commentId,
    this.userId,
    this.route,
    this.event,
    this.extra = const {},
  });

  factory NotificationPayload.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NotificationPayload();

    final data = Map<String, dynamic>.from(json);

    String? read(String key) {
      final value = data[key];
      final text = value?.toString().trim();

      if (text == null || text.isEmpty || text == 'null') {
        return null;
      }

      return text;
    }

    return NotificationPayload(
      conversationId: read('conversation_id') ?? read('conversationId'),
      callId: read('call_id') ?? read('callId'),
      liveId: read('live_id') ?? read('liveId'),
      adId: read('ad_id') ?? read('adId'),
      shortId: read('short_id') ?? read('shortId'),
      commentId: read('comment_id') ?? read('commentId'),
      route: read('route'),
      event: read('event'),
      userId:
          read('user_id') ??
          read('userId') ??
          read('actor_id') ??
          read('actor') ??
          read('sender') ??
          read('caller') ??
          read('follower') ??
          read('host_user'),
      extra: data,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      ...extra,
      if (conversationId != null) 'conversation_id': conversationId,
      if (callId != null) 'call_id': callId,
      if (liveId != null) 'live_id': liveId,
      if (adId != null) 'ad_id': adId,
      if (shortId != null) 'short_id': shortId,
      if (commentId != null) 'comment_id': commentId,
      if (userId != null) 'user_id': userId,
      if (route != null) 'route': route,
      if (event != null) 'event': event,
    };

    return data;
  }
}
