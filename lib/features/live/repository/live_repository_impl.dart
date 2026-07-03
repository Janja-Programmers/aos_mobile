import 'package:africaonlinestores/features/live/data/live_api.dart';
import 'package:africaonlinestores/features/live/domain/live_join_session.dart';
import 'package:africaonlinestores/features/live/domain/live_stream.dart';

// ================= ABSTRACT =================
abstract class LiveRepository {
  Future<LiveJoinSession> startLive({
    required String title,
    required String coverImage,
    required String coverMediaId,
  });

  Future<LiveJoinSession> joinLive({required String liveId});

  Future<void> endLive({required String liveId});

  Future<LiveStream> getLive({required String liveId});

  Future<List<LiveStream>> listLives({int start = 0, int limit = 20});

  Future<String?> trackJoin({required String liveId, String? sessionId});

  Future<void> trackLeave({required String liveId, String? sessionId});

  Future<void> sendReaction({
    required String liveId,
    required String reactionType,
  });
}

// ================= IMPL =================
class LiveRepositoryImpl implements LiveRepository {
  final LiveApi api;

  const LiveRepositoryImpl(this.api);

  // -----------------------------
  // Start Live (Host)
  // -----------------------------
  @override
  Future<LiveJoinSession> startLive({
    required String title,
    required String coverImage,
    required String coverMediaId,
  }) async {
    final res = await api.startLive(
      title: title,
      coverImage: coverImage,
      coverMediaId: coverMediaId,
    );

    return res.fold((e) => throw e, (data) => data);
  }

  // -----------------------------
  // Join Live (Viewer)
  // -----------------------------
  @override
  Future<LiveJoinSession> joinLive({required String liveId}) async {
    final res = await api.joinLive(liveId: liveId);

    return res.fold((e) => throw e, (data) => data);
  }

  // -----------------------------
  // End Live
  // -----------------------------
  @override
  Future<void> endLive({required String liveId}) async {
    final res = await api.endLive(liveId: liveId);

    return res.fold((e) => throw e, (_) => null);
  }

  // -----------------------------
  // Get Live (metadata)
  // -----------------------------
  @override
  Future<LiveStream> getLive({required String liveId}) async {
    final res = await api.getLive(liveId: liveId);

    return res.fold((e) => throw e, (data) => data);
  }

  // -----------------------------
  // List Lives
  // -----------------------------
  @override
  Future<List<LiveStream>> listLives({int start = 0, int limit = 20}) async {
    final res = await api.listLives(start: start, limit: limit);

    return res.fold((e) => throw e, (data) => data);
  }

  // =============================
  // 🔥 TRACK JOIN
  // =============================
  @override
  Future<String?> trackJoin({required String liveId, String? sessionId}) async {
    final res = await api.trackJoin(liveId: liveId, sessionId: sessionId);

    return res.fold((e) => throw e, (data) => data);
  }

  // =============================
  // 🔥 TRACK LEAVE
  // =============================
  @override
  Future<void> trackLeave({required String liveId, String? sessionId}) async {
    final res = await api.trackLeave(liveId: liveId, sessionId: sessionId);

    return res.fold((e) => throw e, (_) => null);
  }

  // =============================
  // 🔥 SEND REACTION
  // =============================
  @override
  Future<void> sendReaction({
    required String liveId,
    required String reactionType,
  }) async {
    final res = await api.sendReaction(
      liveId: liveId,
      reactionType: reactionType,
    );

    return res.fold((e) => throw e, (_) => null);
  }
}
