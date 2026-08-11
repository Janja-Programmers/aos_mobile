import 'dart:async';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/live/application/managers/live_manager.dart';
import 'package:africaonlinestores/features/live/data/live_cohost_api.dart';
import 'package:africaonlinestores/features/live/domain/live_cohost.dart';
import 'package:africaonlinestores/features/live/domain/live_stream.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

@immutable
class LiveCohostState {
  const LiveCohostState({
    this.liveId,
    this.isLoading = false,
    this.isMutating = false,
    this.errorMessage,
    this.items = const <LiveCohost>[],
  });

  final String? liveId;
  final bool isLoading;
  final bool isMutating;
  final String? errorMessage;
  final List<LiveCohost> items;

  LiveCohost? get activeCohost {
    for (final item in items) {
      if (item.isActiveStatus) return item;
    }
    return null;
  }

  LiveCohost? get currentWorkflow {
    for (final item in items) {
      if (item.isPending || item.isAccepted || item.isActiveStatus) return item;
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

class LiveCohostController extends StateNotifier<LiveCohostState> {
  LiveCohostController(this._api, this._liveManager)
    : super(const LiveCohostState());

  final LiveCohostApi _api;
  final LiveManager _liveManager;
  final Set<String> _activatingIds = <String>{};
  int _generation = 0;

  void clear() {
    ++_generation;
    state = const LiveCohostState();
  }

  void hydrate(LiveStream live) {
    _ensureLive(live.id);
    final items = <LiveCohost>[];
    final activeCohost = live.activeCohost;
    if (activeCohost != null) items.add(activeCohost);
    final workflow = live.viewerState.cohostWorkflow;
    if (workflow != null) {
      items.removeWhere((item) => item.id == workflow.id);
      items.add(workflow);
    }
    if (!live.viewerState.isHost) {
      state = state.copyWith(items: items, clearError: true);
    }
    for (final item in items) {
      if (live.viewerState.isHost) {
        state = state.copyWith(items: _upsert(item));
      }
      if (item.isAccepted) unawaited(_activateAccepted(item));
    }
  }

  Future<void> load({required String liveId, String? status}) async {
    _ensureLive(liveId);
    if (state.isLoading) return;

    final generation = _generation;
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _api.listCohosts(liveId: liveId, status: status);
    if (!mounted || generation != _generation || state.liveId != liveId) {
      return;
    }

    state = result.fold(
      (failure) =>
          state.copyWith(isLoading: false, errorMessage: failure.message),
      (items) =>
          state.copyWith(isLoading: false, items: items, clearError: true),
    );
  }

  Future<LiveCohost?> request({
    required String liveId,
    required String sessionId,
  }) {
    _ensureLive(liveId);
    return _mutate(
      () => _api.requestCohost(liveId: liveId, sessionId: sessionId),
    );
  }

  Future<LiveCohost?> invite({
    required String liveId,
    required String livekitIdentity,
  }) {
    _ensureLive(liveId);
    return _mutate(
      () => _api.inviteCohost(liveId: liveId, livekitIdentity: livekitIdentity),
    );
  }

  Future<LiveCohost?> respond({
    required String cohostId,
    required bool accept,
    String? reason,
  }) async {
    final cohost = await _mutate(
      () => _api.respondCohost(
        cohostId: cohostId,
        accept: accept,
        reason: reason,
      ),
    );
    if (cohost != null && cohost.isAccepted) {
      await _activateAccepted(cohost);
    }
    return cohost;
  }

  Future<LiveCohost?> cancel({required String cohostId, String? reason}) {
    return _mutate(() => _api.cancelCohost(cohostId: cohostId, reason: reason));
  }

  Future<bool> end({
    required String cohostId,
    bool resumeAsViewer = true,
  }) async {
    if (state.isMutating) return false;
    final generation = _generation;
    final liveId = state.liveId;
    state = state.copyWith(isMutating: true, clearError: true);
    final result = await _api.endCohost(cohostId: cohostId);
    if (!mounted || generation != _generation || state.liveId != liveId) {
      return false;
    }
    final failure = result.leftOrNull;
    if (failure != null) {
      state = state.copyWith(isMutating: false, errorMessage: failure.message);
      return false;
    }

    state = state.copyWith(
      isMutating: false,
      items: state.items
          .where((item) => item.id != cohostId)
          .toList(growable: false),
      clearError: true,
    );
    if (resumeAsViewer &&
        _liveManager.currentState.activeCohostId == cohostId &&
        _liveManager.currentState.isCohost) {
      await _liveManager.returnToViewer();
    }
    return true;
  }

  Future<void> handleRealtime(Map<String, dynamic> data) async {
    if (!mounted) return;
    final raw = data['cohost'] ?? data;
    if (raw is! Map<Object?, Object?>) return;

    final cohost = LiveCohost.fromJson(asJsonMap(raw));
    if (cohost.id.isEmpty || cohost.liveId.isEmpty) return;
    if (state.liveId != null && cohost.liveId != state.liveId) return;

    _ensureLive(cohost.liveId);
    state = state.copyWith(items: _upsert(cohost), clearError: true);

    if (cohost.isAccepted) {
      await _activateAccepted(cohost);
      await _liveManager.refreshActiveLive();
      return;
    }

    if ((cohost.isEnded || cohost.isCancelled || cohost.isRejected) &&
        _liveManager.currentState.activeCohostId == cohost.id &&
        _liveManager.currentState.isCohost) {
      await _liveManager.returnToViewer();
    }
    await _liveManager.refreshActiveLive();
  }

  Future<LiveCohost?> _mutate(
    Future<Either<Failure, LiveCohost>> Function() operation,
  ) async {
    if (state.isMutating) return null;
    final generation = _generation;
    final liveId = state.liveId;
    state = state.copyWith(isMutating: true, clearError: true);

    final result = await operation();
    if (!mounted || generation != _generation || state.liveId != liveId) {
      return null;
    }
    final failure = result.leftOrNull;
    if (failure != null) {
      state = state.copyWith(isMutating: false, errorMessage: failure.message);
      return null;
    }

    final value = result.rightOrNull;
    if (value == null) {
      state = state.copyWith(
        isMutating: false,
        errorMessage: 'Invalid co-host response.',
      );
      return null;
    }

    state = state.copyWith(
      isMutating: false,
      items: _upsert(value),
      clearError: true,
    );
    return value;
  }

  Future<void> _activateAccepted(LiveCohost cohost) async {
    final liveState = _liveManager.currentState;
    final session = liveState.session;
    final generation = _generation;
    if (session == null ||
        liveState.isHost ||
        liveState.isCohost ||
        session.liveId != cohost.liveId ||
        session.sessionId == null ||
        (cohost.sessionId != null && cohost.sessionId != session.sessionId) ||
        !_activatingIds.add(cohost.id)) {
      return;
    }

    try {
      final tokenResult = await _api.getCohostToken(
        cohostId: cohost.id,
        sessionId: session.sessionId,
      );
      if (!mounted) return;
      if (generation != _generation || state.liveId != cohost.liveId) return;
      final failure = tokenResult.leftOrNull;
      if (failure != null) {
        state = state.copyWith(errorMessage: failure.message);
        return;
      }

      final cohostSession = tokenResult.rightOrNull;
      if (cohostSession == null) {
        state = state.copyWith(errorMessage: 'Invalid co-host token response.');
        return;
      }

      final connected = await _liveManager.startCohostSession(
        session: cohostSession,
        cohostId: cohost.id,
      );
      if (!mounted) return;
      if (generation != _generation || state.liveId != cohost.liveId) {
        if (_liveManager.currentState.activeCohostId == cohost.id &&
            _liveManager.currentState.isCohost) {
          await _liveManager.returnToViewer();
        }
        return;
      }
      if (!connected) {
        state = state.copyWith(
          errorMessage: 'Could not connect the co-host media session.',
        );
        return;
      }

      final activation = await _api.activateCohost(
        cohostId: cohost.id,
        sessionId: session.sessionId,
      );
      if (!mounted) return;
      if (generation != _generation || state.liveId != cohost.liveId) {
        if (activation.isRight) {
          await _api.endCohost(cohostId: cohost.id);
        }
        if (_liveManager.currentState.activeCohostId == cohost.id &&
            _liveManager.currentState.isCohost) {
          await _liveManager.returnToViewer();
        }
        return;
      }
      final activationFailure = activation.leftOrNull;
      if (activationFailure != null) {
        state = state.copyWith(errorMessage: activationFailure.message);
        await _liveManager.returnToViewer();
        return;
      }

      final active = activation.rightOrNull;
      if (active != null) {
        if (_liveManager.currentState.activeCohostId != cohost.id ||
            !_liveManager.currentState.isCohost) {
          await _api.endCohost(cohostId: cohost.id);
          return;
        }
        state = state.copyWith(items: _upsert(active), clearError: true);
      }
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'Co-host activation failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        state = state.copyWith(errorMessage: 'Could not activate co-hosting.');
        await _liveManager.returnToViewer();
      }
    } finally {
      _activatingIds.remove(cohost.id);
    }
  }

  void _ensureLive(String liveId) {
    if (state.liveId == liveId) return;
    ++_generation;
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

    final items = <LiveCohost>[...state.items];
    final index = items.indexWhere((item) => item.id == cohost.id);
    if (index < 0) {
      items.insert(0, cohost);
    } else {
      items[index] = cohost;
    }
    return items;
  }
}
