import 'package:africaonlinestores/features/social/safety/data/social_safety_api.dart';
import 'package:flutter_riverpod/legacy.dart';

class SocialUserSearchState {
  final List<SocialUserSummary> items;
  final bool loading;
  final String query;
  final String? error;

  const SocialUserSearchState({
    required this.items,
    required this.loading,
    required this.query,
    required this.error,
  });

  factory SocialUserSearchState.initial() {
    return const SocialUserSearchState(
      items: [],
      loading: false,
      query: '',
      error: null,
    );
  }

  SocialUserSearchState copyWith({
    List<SocialUserSummary>? items,
    bool? loading,
    String? query,
    String? error,
    bool clearError = false,
  }) {
    return SocialUserSearchState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      query: query ?? this.query,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final socialUserSearchControllerProvider =
    StateNotifierProvider.autoDispose<
      SocialUserSearchController,
      SocialUserSearchState
    >((ref) {
      return SocialUserSearchController(ref.read(socialSafetyApiProvider));
    });

class SocialUserSearchController extends StateNotifier<SocialUserSearchState> {
  final SocialSafetyApi api;

  SocialUserSearchController(this.api) : super(SocialUserSearchState.initial());

  Future<void> search(String query) async {
    final clean = query.trim();
    if (clean.length < 2) {
      state = state.copyWith(query: clean, items: const [], clearError: true);
      return;
    }
    state = state.copyWith(loading: true, query: clean, clearError: true);
    final res = await api.searchUsers(query: clean);
    res.fold(
      (f) => state = state.copyWith(loading: false, error: f.message),
      (page) => state = state.copyWith(loading: false, items: page.items),
    );
  }
}
