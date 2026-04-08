import 'package:africaonlinestores/features/shorts/domain/entities/init_short_upload_result.dart';
import 'package:africaonlinestores/features/shorts/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/domain/entities/short_comment.dart';
import 'package:africaonlinestores/features/shorts/domain/entities/short_feed_page.dart';
import 'package:africaonlinestores/features/shorts/domain/entities/short_metrics.dart';
import 'package:africaonlinestores/features/shorts/domain/entities/short_upload_request.dart';

import 'package:africaonlinestores/features/shorts/domain/value_objects/short_id.dart';
import 'package:africaonlinestores/features/shorts/domain/value_objects/comment_id.dart';
import 'package:africaonlinestores/features/shorts/domain/value_objects/caption.dart';

abstract class ShortsRepository {
  // ───────────── FEED ─────────────

  Future<ShortFeedPage> feedForYou({String? cursor});

  Future<ShortFeedPage> feedFollowing({String? cursor});

  Future<ShortFeedPage> feedByAd({required String adId, String? cursor});

  // ───────────── ENGAGEMENT ─────────────

  Future<ShortMetrics> toggleLike({required ShortId shortId});

  // ───────────── COMMENTS ─────────────

  Future<List<ShortComment>> listComments({required ShortId shortId});

  Future<List<ShortComment>> listReplies({required CommentId commentId});

  Future<ShortComment> addComment({
    required ShortId shortId,
    required String content,
  });

  Future<ShortComment> replyComment({
    required CommentId parentCommentId,
    required String content,
  });

  Future<void> deleteComment({required CommentId commentId});

  // ───────────── TRACKING ─────────────

  Future<void> trackImpression({required ShortId shortId});

  Future<void> trackView({required ShortId shortId});

  // ───────────── MANAGEMENT ─────────────

  Future<Short> getShort({required ShortId shortId});

  Future<ShortFeedPage> myShorts({String? cursor});

  Future<void> deleteShort({required ShortId shortId});

  Future<void> retryProcessing({required ShortId shortId});

  // ───────────── UPLOAD ─────────────

  Future<InitShortUploadResult> initUpload({
    required ShortUploadRequest request,
  });

  Future<void> confirmUpload({required ShortId shortId});

  Future<void> updateMetadata({
    required String adId,
    required ShortId shortId,
    Caption? caption,
    List<String>? hashtags,
  });
}
