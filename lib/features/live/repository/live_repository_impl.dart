import 'package:africaonlinestores/features/live/data/live_api.dart';
import 'package:africaonlinestores/features/live/domain/live_bootstrap.dart';
import 'package:africaonlinestores/features/live/domain/live_list_page.dart';
import 'package:africaonlinestores/features/live/domain/live_reaction.dart';
import 'package:africaonlinestores/features/live/domain/live_stream.dart';

abstract class LiveRepository {
  Future<LiveBootstrap> startLive({
    required String title,
    String? coverImage,
    String? coverMediaId,
  });

  Future<LiveBootstrap> joinLive({required String liveId, String? sessionId});

  Future<LiveStream> endLive({required String liveId});

  Future<LiveStream> getLive({required String liveId, String? sessionId});

  Future<LiveListPage> listLives({int limit = 20, String? cursor});

  Future<LiveStream?> trackJoin({
    required String liveId,
    required String sessionId,
  });

  Future<LiveStream?> trackLeave({
    required String liveId,
    required String sessionId,
  });

  Future<LiveReaction> sendReaction({
    required String liveId,
    required LiveReactionType reactionType,
    String? sessionId,
  });

  Future<void> shareLiveToChat({
    required String liveId,
    required String conversationId,
    String? message,
    String? idempotencyKey,
  });
}

class LiveRepositoryImpl implements LiveRepository {
  const LiveRepositoryImpl(this.api);

  final LiveApi api;

  @override
  Future<LiveBootstrap> startLive({
    required String title,
    String? coverImage,
    String? coverMediaId,
  }) async {
    final result = await api.startLive(
      title: title,
      coverImage: coverImage,
      coverMediaId: coverMediaId,
    );
    return result.fold((failure) => throw failure, (value) => value);
  }

  @override
  Future<LiveBootstrap> joinLive({
    required String liveId,
    String? sessionId,
  }) async {
    final result = await api.joinLive(liveId: liveId, sessionId: sessionId);
    return result.fold((failure) => throw failure, (value) => value);
  }

  @override
  Future<LiveStream> endLive({required String liveId}) async {
    final result = await api.endLive(liveId: liveId);
    return result.fold((failure) => throw failure, (value) => value);
  }

  @override
  Future<LiveStream> getLive({
    required String liveId,
    String? sessionId,
  }) async {
    final result = await api.getLive(liveId: liveId, sessionId: sessionId);
    return result.fold((failure) => throw failure, (value) => value);
  }

  @override
  Future<LiveListPage> listLives({int limit = 20, String? cursor}) async {
    final result = await api.listLives(limit: limit, cursor: cursor);
    return result.fold((failure) => throw failure, (value) => value);
  }

  @override
  Future<LiveStream?> trackJoin({
    required String liveId,
    required String sessionId,
  }) async {
    final result = await api.trackJoin(liveId: liveId, sessionId: sessionId);
    return result.fold((failure) => throw failure, (value) => value);
  }

  @override
  Future<LiveStream?> trackLeave({
    required String liveId,
    required String sessionId,
  }) async {
    final result = await api.trackLeave(liveId: liveId, sessionId: sessionId);
    return result.fold((failure) => throw failure, (value) => value);
  }

  @override
  Future<LiveReaction> sendReaction({
    required String liveId,
    required LiveReactionType reactionType,
    String? sessionId,
  }) async {
    final result = await api.sendReaction(
      liveId: liveId,
      reactionType: reactionType,
      sessionId: sessionId,
    );
    return result.fold((failure) => throw failure, (value) => value);
  }

  @override
  Future<void> shareLiveToChat({
    required String liveId,
    required String conversationId,
    String? message,
    String? idempotencyKey,
  }) async {
    final result = await api.shareLiveToChat(
      liveId: liveId,
      conversationId: conversationId,
      message: message,
      idempotencyKey: idempotencyKey,
    );
    return result.fold((failure) => throw failure, (_) {});
  }
}
