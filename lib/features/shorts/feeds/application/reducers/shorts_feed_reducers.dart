import 'package:africaonlinestores/features/shorts/feeds/application/state/shorts_feed_state.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

class ShortsFeedReducer {
  const ShortsFeedReducer();

  ShortsFeedState setLoading(ShortsFeedState state) {
    return state.copyWith(status: ShortsFeedStatus.loading, errorMessage: null);
  }

  ShortsFeedState setReady(
    ShortsFeedState state, {
    required List<Short> items,
    required String? nextCursor,
  }) {
    return state.copyWith(
      status: ShortsFeedStatus.ready,
      shorts: items,
      nextCursor: nextCursor,
      errorMessage: null,
      activeIndex: 0,
    );
  }

  ShortsFeedState append(
    ShortsFeedState state, {
    required List<Short> newItems,
    required String? nextCursor,
  }) {
    return state.copyWith(
      shorts: [...state.shorts, ...newItems],
      nextCursor: nextCursor,
      status: ShortsFeedStatus.ready,
    );
  }

  ShortsFeedState setActiveIndex(ShortsFeedState state, int index) {
    if (index < 0 || index >= state.shorts.length) return state;

    return state.copyWith(activeIndex: index);
  }

  ShortsFeedState setError(ShortsFeedState state, String message) {
    return state.copyWith(
      status: ShortsFeedStatus.error,
      errorMessage: message,
    );
  }

  ShortsFeedState setEmpty(ShortsFeedState state) {
    return state.copyWith(
      status: ShortsFeedStatus.empty,
      shorts: [],
      nextCursor: null,
      activeIndex: 0,
    );
  }
}
