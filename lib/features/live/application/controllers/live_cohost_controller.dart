import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/live/data/live_cohost_api.dart';
import 'package:africaonlinestores/features/live/domain/live_cohost.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

@immutable
class LiveCohostState {
  final String? liveId;
  final bool isLoading;
  final bool isMutating;
  final String? errorMessage;
  final List<LiveCohost> items;

  const LiveCohostState({
    this.liveId,
    this.isLoading = false,
    this.isMutating = false,
    this.errorMessage,
    this.items = const [],
  });

  LiveCohost? get activeCohost {
    for (final item in items) {
      if (item.isActiveStatus) return item;
    }
    return null;
  }

  List<LiveCohost> get pending =>
      items.where((item) => item.isPending).toList(growable: false);

  LiveCohostState copyWith({
    String? liveId,
    bool clearLiveId = false,
    bool? isLoading,
    bool? isMutating,
    String? errorMessage,
    bool clearError = false,
    List<LiveCohost>? items,
  }) {
    return LiveCohostState(
      liveId: clearLiveId ? null : liveId ?? this.liveId,
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      items: items ?? this.items,
    );
  }
}

final liveCohostControllerProvider =
    StateNotifierProvider<LiveCohostController, LiveCohostState>((ref) {
      return LiveCohostController(ref.read(liveCohostApiProvider));
    });

class LiveCohostController extends StateNotifier<LiveCohostState> {
  final LiveCohostApi _api;

  LiveCohostController(this._api) : super(const LiveCohostState());

  Future<void> load({required String liveId, String? status}) async {
    if (state.liveId != liveId) {
      state = LiveCohostState(liveId: liveId, isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    final res = await _api.listCohosts(liveId: liveId, status: status);
    state = res.fold(
      (failure) => state.copyWith(
        liveId: liveId,
        isLoading: false,
        errorMessage: failure.message,
      ),
      (items) => state.copyWith(liveId: liveId, isLoading: false, items: items),
    );
  }

  Future<LiveCohost?> request({
    required String liveId,
    String? sessionId,
  }) async {
    _ensureLive(liveId);
    state = state.copyWith(isMutating: true, clearError: true);
    final res = await _api.requestCohost(liveId: liveId, sessionId: sessionId);
    LiveCohost? created;
    state = res.fold(
      (failure) =>
          state.copyWith(isMutating: false, errorMessage: failure.message),
      (cohost) {
        created = cohost;
        return state.copyWith(isMutating: false, items: _upsert(cohost));
      },
    );
    return created;
  }

  Future<LiveCohost?> invite({
    required String liveId,
    required String targetUser,
    String? sessionId,
  }) async {
    _ensureLive(liveId);
    state = state.copyWith(isMutating: true, clearError: true);
    final res = await _api.inviteCohost(
      liveId: liveId,
      targetUser: targetUser,
      sessionId: sessionId,
    );
    LiveCohost? created;
    state = res.fold(
      (failure) =>
          state.copyWith(isMutating: false, errorMessage: failure.message),
      (cohost) {
        created = cohost;
        return state.copyWith(isMutating: false, items: _upsert(cohost));
      },
    );
    return created;
  }

  Future<LiveCohost?> respond({
    required String cohostId,
    required bool accept,
    String? reason,
  }) async {
    state = state.copyWith(isMutating: true, clearError: true);
    final res = await _api.respondCohost(
      cohostId: cohostId,
      accept: accept,
      reason: reason,
    );
    LiveCohost? updated;
    state = res.fold(
      (failure) =>
          state.copyWith(isMutating: false, errorMessage: failure.message),
      (cohost) {
        updated = cohost;
        return state.copyWith(isMutating: false, items: _upsert(cohost));
      },
    );
    return updated;
  }

  Future<LiveCohost?> activate({
    required String cohostId,
    String? sessionId,
  }) async {
    state = state.copyWith(isMutating: true, clearError: true);
    final res = await _api.activateCohost(
      cohostId: cohostId,
      sessionId: sessionId,
    );
    LiveCohost? updated;
    state = res.fold(
      (failure) =>
          state.copyWith(isMutating: false, errorMessage: failure.message),
      (cohost) {
        updated = cohost;
        return state.copyWith(isMutating: false, items: _upsert(cohost));
      },
    );
    return updated;
  }

  Future<void> end({required String cohostId}) async {
    state = state.copyWith(isMutating: true, clearError: true);
    final res = await _api.endCohost(cohostId: cohostId);
    state = res.fold(
      (failure) =>
          state.copyWith(isMutating: false, errorMessage: failure.message),
      (_) => state.copyWith(
        isMutating: false,
        items: state.items
            .where((item) => item.id != cohostId)
            .toList(growable: false),
      ),
    );
  }

  LiveCohost? applyRealtime(Map<String, dynamic> data) {
    final raw = data['cohost'] ?? data;
    if (raw is! Map) return null;

    final cohost = LiveCohost.fromJson(asJsonMap(raw));
    if (cohost.id.isEmpty) return null;
    if (state.liveId != null && cohost.liveId != state.liveId) return null;

    state = state.copyWith(items: _upsert(cohost));
    return cohost;
  }

  void _ensureLive(String liveId) {
    if (state.liveId == liveId) return;
    state = LiveCohostState(liveId: liveId);
  }

  List<LiveCohost> _upsert(LiveCohost cohost) {
    if (state.liveId != null && cohost.liveId != state.liveId) {
      return state.items;
    }

    if (cohost.isRejected || cohost.isCancelled || cohost.isEnded) {
      return state.items
          .where((item) => item.id != cohost.id)
          .toList(growable: false);
    }

    final items = [...state.items];
    final index = items.indexWhere((item) => item.id == cohost.id);
    if (index == -1) {
      items.insert(0, cohost);
    } else {
      items[index] = cohost;
    }
    return items;
  }
}
