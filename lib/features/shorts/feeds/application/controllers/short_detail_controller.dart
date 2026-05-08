import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/shorts/feeds/application/state/short_detail_state.dart';
import 'package:africaonlinestores/features/shorts/feeds/repository/short_feed_repository.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_engagement_api.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

class ShortDetailController extends StateNotifier<ShortDetailState> {
  static const int _loadMoreThreshold = 2;

  final ShortsRepository _repository;
  final ShortsEngagementApi _engagementApi;

  ShortDetailController({
    required ShortDetailArgs args,
    required ShortsRepository repository,
    required ShortsEngagementApi engagementApi,
  }) : _repository = repository,
       _engagementApi = engagementApi,
       super(
         ShortDetailState.initial(
           items: args.initialShorts,
           nextCursor: args.initialNextCursor,
           hasMore: args.initialHasMore,
           currentIndex: args.initialIndex,
         ),
       );

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.nextCursor == null) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    try {
      final page = await _repository.fetchForYou(
        limit: 10,
        cursor: state.nextCursor,
      );

      state = state.copyWith(
        items: List.unmodifiable([...state.items, ...page.items]),
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        isLoadingMore: false,
      );
    } catch (e) {
      debugPrint('Error loading more shorts: $e');

      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Failed to load more shorts.',
      );
    }
  }

  Future<void> toggleLike(String shortId) async {
    if (state.pendingLikeIds.contains(shortId)) return;

    final index = state.items.indexWhere((short) => short.id.value == shortId);
    if (index == -1) return;

    final originalShort = state.items[index];
    final wasLiked = originalShort.isLiked;

    final optimisticShort = originalShort.copyWith(
      metrics: originalShort.metrics.copyWith(
        likedByMe: !wasLiked,
        likeCount: wasLiked
            ? (originalShort.metrics.likeCount - 1).clamp(0, 1 << 31)
            : originalShort.metrics.likeCount + 1,
      ),
      viewerState: originalShort.viewerState.copyWith(liked: !wasLiked),
    );

    _replaceShortAt(
      index,
      optimisticShort,
      pendingLikeIds: {...state.pendingLikeIds, shortId},
    );

    final result = await _engagementApi.toggleLike(shortId: shortId);

    result.fold(
      (failure) {
        debugPrint('Toggle like failed: ${failure.message}');

        final rollbackIndex = state.items.indexWhere(
          (short) => short.id.value == shortId,
        );

        final updatedPending = {...state.pendingLikeIds}..remove(shortId);

        if (rollbackIndex == -1) {
          state = state.copyWith(pendingLikeIds: updatedPending);
          return;
        }

        _replaceShortAt(
          rollbackIndex,
          originalShort,
          pendingLikeIds: updatedPending,
        );
      },
      (toggleResult) {
        final syncIndex = state.items.indexWhere(
          (short) => short.id.value == toggleResult.shortId,
        );

        final updatedPending = {...state.pendingLikeIds}..remove(shortId);

        if (syncIndex == -1) {
          state = state.copyWith(pendingLikeIds: updatedPending);
          return;
        }

        final currentShort = state.items[syncIndex];
        final currentlyLiked = currentShort.isLiked;

        var correctedLikeCount = currentShort.metrics.likeCount;

        if (toggleResult.liked != currentlyLiked) {
          correctedLikeCount = toggleResult.liked
              ? currentShort.metrics.likeCount + 1
              : (currentShort.metrics.likeCount - 1).clamp(0, 1 << 31);
        }

        final syncedShort = currentShort.copyWith(
          metrics: currentShort.metrics.copyWith(
            likedByMe: toggleResult.liked,
            likeCount: correctedLikeCount,
          ),
          viewerState: currentShort.viewerState.copyWith(
            liked: toggleResult.liked,
          ),
        );

        _replaceShortAt(syncIndex, syncedShort, pendingLikeIds: updatedPending);
      },
    );
  }

  void onPageChanged(int index) {
    if (index < 0 || index >= state.items.length) return;

    state = state.copyWith(currentIndex: index);

    if (index >= state.items.length - _loadMoreThreshold) {
      loadMore();
    }
  }

  bool shouldPrepareVideo(int index) {
    return (index - state.currentIndex).abs() <= 1;
  }

  void incrementCommentCount(String shortId) {
    final index = state.items.indexWhere((short) => short.id.value == shortId);
    if (index == -1) return;

    final short = state.items[index];

    final updatedShort = short.copyWith(
      metrics: short.metrics.copyWith(
        commentCount: short.metrics.commentCount + 1,
      ),
    );

    _replaceShortAt(index, updatedShort);
  }

  void _replaceShortAt(
    int index,
    Short updatedShort, {
    Set<String>? pendingLikeIds,
  }) {
    if (index < 0 || index >= state.items.length) return;

    final updatedItems = [...state.items];
    updatedItems[index] = updatedShort;

    state = state.copyWith(
      items: List.unmodifiable(updatedItems),
      pendingLikeIds: pendingLikeIds,
    );
  }
}
