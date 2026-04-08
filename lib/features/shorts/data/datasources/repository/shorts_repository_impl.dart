import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/shorts/data/datasources/api/shorts_comments_api.dart';
import 'package:africaonlinestores/features/shorts/data/datasources/api/shorts_engagement_api.dart';
import 'package:africaonlinestores/features/shorts/data/datasources/api/shorts_feed_api.dart';
import 'package:africaonlinestores/features/shorts/data/datasources/api/shorts_management_api.dart';
import 'package:africaonlinestores/features/shorts/data/datasources/api/shorts_tracking_api.dart.dart';
import 'package:africaonlinestores/features/shorts/data/datasources/api/shorts_upload_api.dart';
import 'package:africaonlinestores/features/shorts/data/mappers/comment_mapper.dart';
import 'package:africaonlinestores/features/shorts/data/mappers/metrics_mapper.dart';
import 'package:africaonlinestores/features/shorts/data/mappers/short_mapper.dart';
import 'package:africaonlinestores/features/shorts/data/models/short_comment_model.dart';
import 'package:africaonlinestores/features/shorts/data/models/short_model.dart';
import 'package:africaonlinestores/features/shorts/domain/entities/init_short_upload_result.dart';
import 'package:africaonlinestores/features/shorts/domain/entities/short.dart';
import 'package:africaonlinestores/features/shorts/domain/entities/short_comment.dart';
import 'package:africaonlinestores/features/shorts/domain/entities/short_feed_page.dart';
import 'package:africaonlinestores/features/shorts/domain/entities/short_metrics.dart';
import 'package:africaonlinestores/features/shorts/domain/entities/short_upload_request.dart';
import 'package:africaonlinestores/features/shorts/domain/repository/shorts_repository.dart';
import 'package:africaonlinestores/features/shorts/domain/value_objects/caption.dart';
import 'package:africaonlinestores/features/shorts/domain/value_objects/comment_id.dart';
import 'package:africaonlinestores/features/shorts/domain/value_objects/short_id.dart';

class ShortsRepositoryImpl implements ShortsRepository {
  final ShortsFeedApi _feedApi;
  final ShortsManagementApi _managementApi;
  final ShortsUploadApi _uploadApi;
  final ShortsEngagementApi _engagementApi;
  final ShortsCommentsApi _commentsApi;
  final ShortsTrackingApi _trackingApi;

  ShortsRepositoryImpl({
    required ShortsFeedApi feedApi,
    required ShortsManagementApi managementApi,
    required ShortsUploadApi uploadApi,
    required ShortsEngagementApi engagementApi,
    required ShortsCommentsApi commentsApi,
    required ShortsTrackingApi trackingApi,
  }) : _feedApi = feedApi,
       _managementApi = managementApi,
       _uploadApi = uploadApi,
       _engagementApi = engagementApi,
       _commentsApi = commentsApi,
       _trackingApi = trackingApi;

  // ───────────── FEED ─────────────

  @override
  Future<ShortFeedPage> feedForYou({String? cursor}) async {
    final result = await _feedApi.fetchForYou(cursor: cursor);

    return result.fold((failure) => throw failure, (json) {
      final data = json['data'] ?? {};
      final items = (data['items'] as List<dynamic>? ?? [])
          .map(
            (e) => ShortMapper.toDomain(
              ShortModel.fromJson(e as Map<String, dynamic>),
            ),
          )
          .toList();

      return ShortFeedPage(
        items: items,
        nextCursor: data['next_cursor'] as String?,
        hasMore: data['has_more'] ?? false,
      );
    });
  }

  @override
  Future<ShortFeedPage> feedFollowing({String? cursor}) async {
    final result = await _feedApi.fetchFollowing(cursor: cursor);

    return result.fold((failure) => throw failure, (json) {
      final data = json['data'] ?? {};
      final items = (data['items'] as List<dynamic>? ?? [])
          .map(
            (e) => ShortMapper.toDomain(
              ShortModel.fromJson(e as Map<String, dynamic>),
            ),
          )
          .toList();

      return ShortFeedPage(
        items: items,
        nextCursor: data['next_cursor'] as String?,
        hasMore: data['has_more'] ?? false,
      );
    });
  }

  @override
  Future<ShortFeedPage> feedByAd({required String adId, String? cursor}) async {
    final result = await _feedApi.fetchByAd(adId: adId, cursor: cursor);

    return result.fold((failure) => throw failure, (json) {
      final data = json['data'] ?? {};
      final items = (data['items'] as List<dynamic>? ?? [])
          .map(
            (e) => ShortMapper.toDomain(
              ShortModel.fromJson(e as Map<String, dynamic>),
            ),
          )
          .toList();

      return ShortFeedPage(
        items: items,
        nextCursor: data['next_cursor'] as String?,
        hasMore: data['has_more'] ?? false,
      );
    });
  }

  // ───────────── MANAGEMENT ─────────────

  @override
  Future<Short> getShort({required ShortId shortId}) async {
    final result = await _managementApi.getShort(shortId: shortId.value);

    return result.fold((failure) => throw failure, (json) {
      final item = json['data']?['item'];

      return ShortMapper.toDomain(ShortModel.fromJson(item));
    });
  }

  @override
  Future<ShortFeedPage> myShorts({String? cursor}) async {
    final result = await _managementApi.myShorts(cursor: cursor);

    return result.fold((failure) => throw failure, (json) {
      final data = json['data'] ?? {};
      final items = (data['items'] as List<dynamic>? ?? [])
          .map(
            (e) => ShortMapper.toDomain(
              ShortModel.fromJson(e as Map<String, dynamic>),
            ),
          )
          .toList();

      return ShortFeedPage(
        items: items,
        nextCursor: data['next_cursor'] as String?,
        hasMore: data['has_more'] ?? false,
      );
    });
  }

  @override
  Future<void> deleteShort({required ShortId shortId}) async {
    final result = await _managementApi.deleteShort(shortId: shortId.value);

    result.fold((failure) => throw failure, (_) {});
  }

  @override
  Future<void> retryProcessing({required ShortId shortId}) async {
    final result = await _managementApi.retryProcessing(shortId: shortId.value);

    result.fold((failure) => throw failure, (_) {});
  }

  // ───────────── ENGAGEMENT ─────────────

  @override
  Future<ShortMetrics> toggleLike({required ShortId shortId}) async {
    final result = await _engagementApi.toggleLike(shortId: shortId.value);

    return result.fold((failure) => throw failure, (json) {
      final data = json['data'] ?? {};
      return MetricsMapper.toDomain(ShortModel.fromJson(data).metrics);
    });
  }

  // ───────────── COMMENTS ─────────────

  @override
  Future<List<ShortComment>> listComments({required ShortId shortId}) async {
    final result = await _commentsApi.listComments(shortId: shortId.value);

    return result.fold((failure) => throw failure, (json) {
      final data = json['data'] ?? {};
      final items = (data['items'] as List<dynamic>? ?? [])
          .map(
            (e) => CommentMapper.toDomain(
              ShortCommentModel.fromJson(e as Map<String, dynamic>),
            ),
          )
          .toList();

      return items;
    });
  }

  @override
  Future<List<ShortComment>> listReplies({required CommentId commentId}) async {
    final result = await _commentsApi.listReplies(commentId: commentId.value);

    return result.fold((failure) => throw failure, (json) {
      final data = json['data'] ?? {};
      final items = (data['items'] as List<dynamic>? ?? [])
          .map(
            (e) => CommentMapper.toDomain(
              ShortCommentModel.fromJson(e as Map<String, dynamic>),
            ),
          )
          .toList();

      return items;
    });
  }

  @override
  Future<ShortComment> addComment({
    required ShortId shortId,
    required String content,
  }) async {
    final result = await _commentsApi.addComment(
      shortId: shortId.value,
      content: content,
    );

    return result.fold((failure) => throw failure, (json) {
      final item = json['data']?['item'];

      return CommentMapper.toDomain(ShortCommentModel.fromJson(item));
    });
  }

  @override
  Future<ShortComment> replyComment({
    required CommentId parentCommentId,
    required String content,
  }) async {
    final result = await _commentsApi.replyComment(
      parentCommentId: parentCommentId.value,
      content: content,
    );

    return result.fold((failure) => throw failure, (json) {
      final item = json['data']?['item'];

      return CommentMapper.toDomain(ShortCommentModel.fromJson(item));
    });
  }

  @override
  Future<void> deleteComment({required CommentId commentId}) async {
    final result = await _commentsApi.deleteComment(commentId: commentId.value);

    result.fold((failure) => throw failure, (_) {});
  }

  // ───────────── TRACKING ─────────────

  @override
  Future<void> trackImpression({required ShortId shortId}) async {
    final result = await _trackingApi.trackImpression(shortId: shortId.value);

    result.fold((failure) => throw failure, (_) {});
  }

  @override
  Future<void> trackView({required ShortId shortId}) async {
    final result = await _trackingApi.trackView(shortId: shortId.value);

    result.fold((failure) => throw failure, (_) {});
  }

  // ───────────── UPLOAD ─────────────

  @override
  Future<InitShortUploadResult> initUpload({
    required ShortUploadRequest request,
  }) async {
    final result = await _uploadApi.initUpload(
      filename: request.filePath.split('/').last,
      contentType: 'video/mp4',
    );

    return result.fold((failure) => throw failure, (json) {
      final data = json['data'] ?? {};

      return InitShortUploadResult(
        shortId: ShortId(data['short_id']),
        uploadUrl: data['upload_url'],
        fileKey: data['file_key'],
      );
    });
  }

  @override
  Future<void> confirmUpload({required ShortId shortId}) async {
    final result = await _uploadApi.confirmUpload(shortId: shortId.value);

    result.fold((failure) => throw failure, (_) {});
  }

  @override
  Future<void> updateMetadata({
    required String adId,
    required ShortId shortId,
    Caption? caption,
    List<String>? hashtags,
  }) async {
    final result = await _uploadApi.updateMetadata(
      adId: adId,
      shortId: shortId.value,
      caption: caption?.value,
      hashtags: hashtags,
    );

    result.fold((failure) => throw failure, (_) {});
  }
}
