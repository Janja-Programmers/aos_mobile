import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/core/utils/media_url.dart';

class NotificationPayload {
  const NotificationPayload({
    this.conversationId,
    this.messageId,
    this.callId,
    this.liveId,
    this.adId,
    this.reviewId,
    this.shortId,
    this.commentId,
    this.userId,
    this.otherUser,
    this.actorName,
    this.actorAvatar,
    this.otherUserName,
    this.route,
    this.event,
    this.notificationType,
    this.extra = const <String, dynamic>{},
  });

  final String? conversationId;
  final String? messageId;
  final String? callId;
  final String? liveId;
  final String? adId;
  final String? reviewId;
  final String? shortId;
  final String? commentId;
  final String? userId;
  final String? otherUser;
  final String? actorName;
  final String? actorAvatar;
  final String? otherUserName;
  final String? route;
  final String? event;
  final String? notificationType;
  final Map<String, dynamic> extra;

  factory NotificationPayload.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const NotificationPayload();
    }

    final Map<String, dynamic> data = asJsonMap(json);

    String? read(String key) {
      final String? text = data[key]?.toString().trim();
      if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
        return null;
      }
      return text;
    }

    final String? userId =
        read('user_id') ??
        read('userId') ??
        read('target_user') ??
        read('targetUser') ??
        read('actor_id') ??
        read('actor') ??
        read('sender_account_id') ??
        read('sender') ??
        read('caller_account_id') ??
        read('caller') ??
        read('follower') ??
        read('host_user');

    final String? otherUser =
        read('other_user') ??
        read('otherUser') ??
        read('sender_account_id') ??
        read('sender') ??
        read('caller_account_id') ??
        read('caller') ??
        read('actor') ??
        read('follower');

    return NotificationPayload(
      conversationId:
          read('conversation_id') ??
          read('conversationId') ??
          read('conversation'),
      messageId: read('message_id') ?? read('messageId'),
      callId: read('call_id') ?? read('callId') ?? read('call'),
      liveId: read('live_id') ?? read('liveId') ?? read('live'),
      adId: read('ad_id') ?? read('adId') ?? read('ad'),
      reviewId: read('review_id') ?? read('reviewId') ?? read('review'),
      shortId:
          read('short_id') ??
          read('shortId') ??
          read('short') ??
          read('short_name') ??
          read('shortName'),
      commentId: read('comment_id') ?? read('commentId') ?? read('comment'),
      userId: userId,
      otherUser: otherUser,
      actorName:
          read('actor_display_name') ??
          read('actor_name') ??
          read('actorName') ??
          read('sender_display_name') ??
          read('caller_display_name') ??
          read('follower_display_name') ??
          read('display_name'),
      actorAvatar: normalizeMediaUrl(
        read('actor_avatar') ??
            read('actorAvatar') ??
            read('sender_avatar') ??
            read('caller_avatar') ??
            read('follower_avatar') ??
            read('avatar'),
      ),
      otherUserName:
          read('other_user_display_name') ??
          read('otherUserDisplayName') ??
          read('sender_display_name') ??
          read('caller_display_name') ??
          read('actor_display_name') ??
          read('actor_name'),
      route: read('route'),
      event: read('event'),
      notificationType:
          read('notification_type') ?? read('notificationType') ?? read('type'),
      extra: data,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...extra,
      if (conversationId != null) 'conversation_id': conversationId,
      if (messageId != null) 'message_id': messageId,
      if (callId != null) 'call_id': callId,
      if (liveId != null) 'live_id': liveId,
      if (adId != null) 'ad_id': adId,
      if (reviewId != null) 'review_id': reviewId,
      if (shortId != null) 'short_id': shortId,
      if (commentId != null) 'comment_id': commentId,
      if (userId != null) 'user_id': userId,
      if (otherUser != null) 'other_user': otherUser,
      if (actorName != null) 'actor_name': actorName,
      if (actorAvatar != null) 'actor_avatar': actorAvatar,
      if (otherUserName != null) 'other_user_display_name': otherUserName,
      if (route != null) 'route': route,
      if (event != null) 'event': event,
      if (notificationType != null) 'notification_type': notificationType,
    };
  }
}
