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
          metrics: currentShort.metrics.copyWith(likeCount: correctedLikeCount),
          viewerState: currentShort.viewerState.copyWith(
            liked: toggleResult.liked,
          ),
        );

        _replaceShortAt(syncIndex, syncedShort, pendingLikeIds: updatedPending);
      },
    );
  }

  Future<void> toggleFollow(String targetUser) async {
    final normalizedTargetUser = targetUser.trim();

    if (normalizedTargetUser.isEmpty) return;

    if (state.pendingFollowUserIds.contains(normalizedTargetUser)) {
      return;
    }

    final affectedIndexes = _indexesForCreator(normalizedTargetUser);
    if (affectedIndexes.isEmpty) return;

    final originalItems = state.items;
    final firstShort = originalItems[affectedIndexes.first];

    if (firstShort.viewerState.isSelf) {
      return;
    }

    final wasFollowing = firstShort.viewerState.isFollowing;
    final isFollowedBy = firstShort.viewerState.isFollowedBy;
    final nextIsFollowing = !wasFollowing;
    final nextIsFriend = nextIsFollowing && isFollowedBy;

    final optimisticItems = _copyItemsWithCreatorRelationship(
      items: originalItems,
      targetUser: normalizedTargetUser,
      isFollowing: nextIsFollowing,
      isFollowedBy: isFollowedBy,
      isFriend: nextIsFriend,
      relationshipStatus: _relationshipStatusFor(
        isFollowing: nextIsFollowing,
        isFollowedBy: isFollowedBy,
      ),
      actionLabel: nextIsFollowing ? 'Following' : 'Follow',
    );

    state = state.copyWith(
      items: optimisticItems,
      pendingFollowUserIds: {
        ...state.pendingFollowUserIds,
        normalizedTargetUser,
      },
      errorMessage: null,
    );

    final result = await _engagementApi.toggleFollow(
      targetUser: normalizedTargetUser,
    );

    result.fold(
      (failure) {
        debugPrint('Toggle follow failed: ${failure.message}');

        final updatedPending = {...state.pendingFollowUserIds}
          ..remove(normalizedTargetUser);

        state = state.copyWith(
          items: originalItems,
          pendingFollowUserIds: updatedPending,
          errorMessage: failure.message,
        );
      },
      (toggleResult) {
        final updatedPending = {...state.pendingFollowUserIds}
          ..remove(normalizedTargetUser);

        final syncedTargetUser = toggleResult.targetUser.trim().isEmpty
            ? normalizedTargetUser
            : toggleResult.targetUser.trim();

        final syncedItems = _copyItemsWithCreatorRelationship(
          items: state.items,
          targetUser: syncedTargetUser,
          isFollowing: toggleResult.isFollowing,
          isFollowedBy: toggleResult.isFollowedBy,
          isFriend: toggleResult.isFriend,
          relationshipStatus: toggleResult.relationshipStatus,
          actionLabel: toggleResult.actionLabel,
        );

        state = state.copyWith(
          items: syncedItems,
          pendingFollowUserIds: updatedPending,
          errorMessage: null,
        );
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

  List<int> _indexesForCreator(String targetUser) {
    final normalizedTargetUser = targetUser.trim();
    if (normalizedTargetUser.isEmpty) return const [];

    final indexes = <int>[];

    for (var i = 0; i < state.items.length; i++) {
      final short = state.items[i];

      if (_matchesCreator(short, normalizedTargetUser)) {
        indexes.add(i);
      }
    }

    return indexes;
  }

  bool _matchesCreator(Short short, String targetUser) {
    final normalizedTargetUser = targetUser.trim();
    if (normalizedTargetUser.isEmpty) return false;

    final creatorUser = short.creator.user.trim();
    final viewerTargetUser = short.viewerState.targetUser?.trim() ?? '';
    final sellerId = short.sellerId.trim();

    return creatorUser == normalizedTargetUser ||
        viewerTargetUser == normalizedTargetUser ||
        sellerId == normalizedTargetUser;
  }

  List<Short> _copyItemsWithCreatorRelationship({
    required List<Short> items,
    required String targetUser,
    required bool isFollowing,
    required bool isFollowedBy,
    required bool isFriend,
    required String relationshipStatus,
    required String actionLabel,
  }) {
    final updatedItems = items
        .map((short) {
          if (!_matchesCreator(short, targetUser)) {
            return short;
          }

          if (short.viewerState.isSelf) {
            return short;
          }

          return short.copyWith(
            viewerState: short.viewerState.copyWith(
              isFollowing: isFollowing,
              isFollowedBy: isFollowedBy,
              isFriend: isFriend,
              relationshipStatus: relationshipStatus,
              actionLabel: actionLabel,
            ),
          );
        })
        .toList(growable: false);

    return List.unmodifiable(updatedItems);
  }

  String _relationshipStatusFor({
    required bool isFollowing,
    required bool isFollowedBy,
  }) {
    if (isFollowing && isFollowedBy) return 'friends';
    if (isFollowing) return 'following';
    if (isFollowedBy) return 'followed_by';

    return 'none';
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
