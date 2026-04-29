import 'package:africaonlinestores/features/live/data/live_api.dart';
import 'package:africaonlinestores/features/live/domain/live_stream.dart';
import 'package:africaonlinestores/features/live/domain/live_join_session.dart';

// ================= ABSTRACT =================
abstract class LiveRepository {
  Future<LiveJoinSession> startLive({
    required String title,
    required String coverImage,
  });

  Future<LiveJoinSession> joinLive({required String liveId});

  Future<void> endLive({required String liveId});

  Future<LiveStream> getLive({required String liveId});

  Future<String?> trackJoin({required String liveId});

  Future<void> trackLeave({required String liveId});
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
  }) async {
    final res = await api.startLive(title: title, coverImage: coverImage);

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

  // =============================
  // 🔥 TRACK JOIN
  // =============================
  @override
  Future<String?> trackJoin({required String liveId}) async {
    final res = await api.trackJoin(liveId: liveId);

    return res.fold((e) => throw e, (data) => data);
  }

  // =============================
  // 🔥 TRACK LEAVE
  // =============================
  @override
  Future<void> trackLeave({required String liveId}) async {
    final res = await api.trackLeave(liveId: liveId);

    return res.fold((e) => throw e, (_) => null);
  }
}
