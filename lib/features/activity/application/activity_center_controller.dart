import 'package:africaonlinestores/features/activity/data/activity_api.dart';
import 'package:flutter_riverpod/legacy.dart';

class ActivityCenterState {
  final List<ActivityItem> items;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final int start;
  final String group;
  final String? error;

  const ActivityCenterState({
    required this.items,
    required this.loading,
    required this.loadingMore,
    required this.hasMore,
    required this.start,
    required this.group,
    required this.error,
  });

  factory ActivityCenterState.initial() {
    return const ActivityCenterState(
      items: [],
      loading: false,
      loadingMore: false,
      hasMore: true,
      start: 0,
      group: 'All',
      error: null,
    );
  }

  ActivityCenterState copyWith({
    List<ActivityItem>? items,
    bool? loading,
    bool? loadingMore,
    bool? hasMore,
    int? start,
    String? group,
    String? error,
    bool clearError = false,
  }) {
    return ActivityCenterState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      start: start ?? this.start,
      group: group ?? this.group,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final activityCenterControllerProvider =
    StateNotifierProvider.autoDispose<
      ActivityCenterController,
      ActivityCenterState
    >((ref) {
      return ActivityCenterController(ref.read(activityApiProvider));
    });

class ActivityCenterController extends StateNotifier<ActivityCenterState> {
  final ActivityApi api;

  ActivityCenterController(this.api) : super(ActivityCenterState.initial());

  Future<void> load({String? group}) async {
    final nextGroup = group ?? state.group;
    state = state.copyWith(
      loading: true,
      group: nextGroup,
      start: 0,
      hasMore: true,
      clearError: true,
    );
    final res = await api.listActivity(group: nextGroup);
    res.fold(
      (f) => state = state.copyWith(loading: false, error: f.message),
      (page) => state = state.copyWith(
        loading: false,
        items: page.items,
        start: page.items.length,
        hasMore: page.hasMore,
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) return;
    state = state.copyWith(loadingMore: true, clearError: true);
    final res = await api.listActivity(start: state.start, group: state.group);
    res.fold(
      (f) => state = state.copyWith(loadingMore: false, error: f.message),
      (page) {
        final byId = <String, ActivityItem>{
          for (final item in state.items) item.id: item,
        };
        for (final item in page.items) {
          byId[item.id] = item;
        }

        state = state.copyWith(
          loadingMore: false,
          items: List.unmodifiable(byId.values),
          start: state.start + page.items.length,
          hasMore: page.hasMore,
        );
      },
    );
  }

  Future<void> hide(String id) async {
    final previous = state.items;
    state = state.copyWith(items: previous.where((e) => e.id != id).toList());
    final res = await api.hideActivity(id);
    if (res.isLeft) {
      state = state.copyWith(items: previous, error: res.leftOrNull?.message);
    }
  }

  Future<void> clearCurrentGroup() async {
    final group = state.group;
    state = state.copyWith(items: const [], start: 0, hasMore: false);
    final res = await api.clearActivity(group: group);
    if (res.isLeft) {
      state = state.copyWith(error: res.leftOrNull?.message);
      await load(group: group);
    }
  }
}
