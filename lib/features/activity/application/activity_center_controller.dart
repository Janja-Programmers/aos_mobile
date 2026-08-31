import 'dart:async';
import 'dart:math' as math;

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/activity/data/activity_api.dart';
import 'package:flutter_riverpod/legacy.dart';

class ActivityCenterState {
  const ActivityCenterState({
    required this.items,
    required this.loading,
    required this.loadingMore,
    required this.hasMore,
    required this.start,
    required this.total,
    required this.group,
    required this.hasLoaded,
    required this.error,
  });

  final List<ActivityItem> items;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final int start;
  final int total;
  final String group;
  final bool hasLoaded;
  final String? error;

  factory ActivityCenterState.initial() {
    return const ActivityCenterState(
      items: <ActivityItem>[],
      loading: false,
      loadingMore: false,
      hasMore: true,
      start: 0,
      total: 0,
      group: 'All',
      hasLoaded: false,
      error: null,
    );
  }

  ActivityCenterState copyWith({
    List<ActivityItem>? items,
    bool? loading,
    bool? loadingMore,
    bool? hasMore,
    int? start,
    int? total,
    String? group,
    bool? hasLoaded,
    String? error,
    bool clearError = false,
  }) {
    return ActivityCenterState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      start: start ?? this.start,
      total: total ?? this.total,
      group: group ?? this.group,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final activityCenterControllerProvider =
    StateNotifierProvider.autoDispose<
      ActivityCenterController,
      ActivityCenterState
    >((ref) {
      return ActivityCenterController(ref.read(activityRepositoryProvider));
    });

class ActivityCenterController extends StateNotifier<ActivityCenterState> {
  ActivityCenterController(this._repository)
    : super(ActivityCenterState.initial());

  final ActivityRepository _repository;
  final Set<String> _hidingIds = <String>{};
  int _requestGeneration = 0;
  bool _isDisposed = false;
  bool _clearInFlight = false;
  bool _hideReconcileNeeded = false;
  bool _hideRefreshNeeded = false;
  String? _hideFailureMessage;
  Completer<void>? _hidesSettledCompleter;

  Future<void> load({String? group}) async {
    final String nextGroup = group ?? state.group;
    final bool groupChanged = nextGroup != state.group;
    final int generation = ++_requestGeneration;
    state = state.copyWith(
      items: groupChanged ? const <ActivityItem>[] : null,
      loading: true,
      loadingMore: false,
      group: nextGroup,
      start: 0,
      total: groupChanged ? 0 : state.total,
      hasMore: true,
      hasLoaded: !groupChanged && state.hasLoaded,
      clearError: true,
    );

    final Either<Failure, ActivityPage> result = await _repository.listActivity(
      group: nextGroup,
    );
    if (_isDisposed ||
        generation != _requestGeneration ||
        state.group != nextGroup) {
      return;
    }

    final Failure? failure = result.leftOrNull;
    if (failure != null) {
      state = state.copyWith(
        loading: false,
        hasLoaded: state.hasLoaded,
        error: failure.message,
      );
      return;
    }

    final ActivityPage page = result.rightOrNull!;
    state = state.copyWith(
      loading: false,
      loadingMore: false,
      items: _sortAndDedupe(page.items),
      start: page.start + page.items.length,
      total: page.total,
      hasMore: page.hasMore,
      hasLoaded: true,
      clearError: true,
    );
  }

  Future<void> loadMore() async {
    if (state.loading ||
        state.loadingMore ||
        !state.hasMore ||
        _hidingIds.isNotEmpty ||
        _clearInFlight) {
      return;
    }
    final int generation = _requestGeneration;
    final String group = state.group;
    final int start = state.start;
    state = state.copyWith(loadingMore: true, clearError: true);

    final Either<Failure, ActivityPage> result = await _repository.listActivity(
      start: start,
      group: group,
    );
    if (_isDisposed ||
        generation != _requestGeneration ||
        state.group != group) {
      return;
    }

    final Failure? failure = result.leftOrNull;
    if (failure != null) {
      state = state.copyWith(loadingMore: false, error: failure.message);
      return;
    }

    final ActivityPage page = result.rightOrNull!;
    state = state.copyWith(
      loadingMore: false,
      items: _merge(state.items, page.items),
      start: page.start + page.items.length,
      total: page.total,
      hasMore: page.hasMore,
      clearError: true,
    );
  }

  Future<void> hide(String id) async {
    final String activityId = id.trim();
    if (_clearInFlight || activityId.isEmpty || !_hidingIds.add(activityId)) {
      return;
    }
    _hidesSettledCompleter ??= Completer<void>();
    try {
      final int index = state.items.indexWhere(
        (ActivityItem item) => item.id == activityId,
      );
      if (index == -1) return;

      // Invalidate any in-flight offset page. Once a visible row is hidden the
      // backend's offsets shift by one and an older response must not append.
      final String operationGroup = state.group;
      final int mutationGeneration = ++_requestGeneration;
      final List<ActivityItem> items = List<ActivityItem>.of(state.items)
        ..removeAt(index);
      state = state.copyWith(
        items: items,
        loading: false,
        loadingMore: false,
        clearError: true,
      );

      final Either<Failure, String> result = await _repository.hideActivity(
        activityId,
      );
      if (_isDisposed) return;
      final Failure? failure = result.leftOrNull;
      if (failure != null) {
        _hideReconcileNeeded = true;
        _hideFailureMessage ??= failure.message;
        return;
      }

      // The hidden row was inside the already-consumed prefix, so the next
      // backend offset moves back by one. This prevents skipping the next row.
      // If the user changed filters/refreshed while the hide was in flight,
      // reconcile instead of applying the old dataset's offset to the new one.
      if (state.group == operationGroup &&
          _requestGeneration == mutationGeneration) {
        final int nextStart = math.max(0, state.start - 1);
        final int nextTotal = math.max(0, state.total - 1);
        state = state.copyWith(
          start: nextStart,
          total: nextTotal,
          hasMore: nextStart < nextTotal,
        );
      } else {
        _hideRefreshNeeded = true;
      }
    } finally {
      _hidingIds.remove(activityId);
      if (!_isDisposed && _hidingIds.isEmpty && _clearInFlight) {
        // A pending group clear supersedes the individual hide result. Avoid
        // flashing an intermediate REST reconciliation while Clear is waiting
        // for this mutation to settle.
        _hideReconcileNeeded = false;
        _hideRefreshNeeded = false;
        _hideFailureMessage = null;
      } else if (!_isDisposed && _hidingIds.isEmpty && _hideReconcileNeeded) {
        final String message =
            _hideFailureMessage ?? 'Failed to hide activity.';
        _hideReconcileNeeded = false;
        _hideRefreshNeeded = false;
        _hideFailureMessage = null;
        await _reconcileAfterMutationFailure(message);
      } else if (!_isDisposed && _hidingIds.isEmpty && _hideRefreshNeeded) {
        _hideRefreshNeeded = false;
        await load(group: state.group);
      }
      if (_hidingIds.isEmpty) {
        final Completer<void>? completer = _hidesSettledCompleter;
        _hidesSettledCompleter = null;
        if (completer != null && !completer.isCompleted) completer.complete();
      }
    }
  }

  Future<void> clearCurrentGroup() async {
    if (_clearInFlight || !state.hasLoaded) return;
    _clearInFlight = true;
    final String group = state.group;
    try {
      _requestGeneration++;
      state = state.copyWith(
        items: const <ActivityItem>[],
        loading: false,
        loadingMore: false,
        start: 0,
        total: 0,
        hasMore: false,
        clearError: true,
      );

      final Completer<void>? pendingHides = _hidesSettledCompleter;
      if (pendingHides != null && !pendingHides.isCompleted) {
        await pendingHides.future;
      }
      if (_isDisposed) return;

      final Either<Failure, int> result = await _repository.clearActivity(
        group: group,
      );
      if (_isDisposed) return;
      final Failure? failure = result.leftOrNull;
      if (failure != null) {
        await _reconcileAfterMutationFailure(failure.message);
        return;
      }

      final String current = state.group;
      if (current == group) {
        state = state.copyWith(
          items: const <ActivityItem>[],
          start: 0,
          total: 0,
          hasMore: false,
          hasLoaded: true,
        );
      } else if (group == 'All' || current == 'All') {
        await load(group: current);
      }
    } finally {
      _clearInFlight = false;
    }
  }

  Future<void> _reconcileAfterMutationFailure(String message) async {
    final String group = state.group;
    final int generation = ++_requestGeneration;
    final Either<Failure, ActivityPage> result = await _repository.listActivity(
      group: group,
    );
    if (_isDisposed ||
        generation != _requestGeneration ||
        state.group != group) {
      return;
    }

    final ActivityPage? page = result.rightOrNull;
    if (page != null) {
      state = state.copyWith(
        items: _sortAndDedupe(page.items),
        loading: false,
        loadingMore: false,
        start: page.start + page.items.length,
        total: page.total,
        hasMore: page.hasMore,
        hasLoaded: true,
        error: message,
      );
      return;
    }
    state = state.copyWith(loading: false, loadingMore: false, error: message);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _requestGeneration++;
    final Completer<void>? completer = _hidesSettledCompleter;
    _hidesSettledCompleter = null;
    if (completer != null && !completer.isCompleted) completer.complete();
    super.dispose();
  }

  List<ActivityItem> _merge(
    List<ActivityItem> current,
    List<ActivityItem> incoming,
  ) {
    final Map<String, ActivityItem> byId = <String, ActivityItem>{
      for (final ActivityItem item in current) item.id: item,
    };
    for (final ActivityItem item in incoming) {
      if (item.id.isNotEmpty) byId[item.id] = item;
    }
    return _sortAndDedupe(byId.values.toList(growable: false));
  }

  List<ActivityItem> _sortAndDedupe(List<ActivityItem> source) {
    final Map<String, ActivityItem> byId = <String, ActivityItem>{
      for (final ActivityItem item in source)
        if (item.id.isNotEmpty) item.id: item,
    };
    final List<ActivityItem> items = byId.values.toList(growable: false);
    items.sort((ActivityItem a, ActivityItem b) {
      final DateTime aTime =
          a.lastOccurrenceAt ??
          a.occurredAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime bTime =
          b.lastOccurrenceAt ??
          b.occurredAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final int timeCompare = bTime.compareTo(aTime);
      return timeCompare != 0 ? timeCompare : b.id.compareTo(a.id);
    });
    return List<ActivityItem>.unmodifiable(items);
  }
}
