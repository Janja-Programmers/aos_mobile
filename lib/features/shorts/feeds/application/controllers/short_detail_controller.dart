import 'dart:async';
import 'dart:io';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/short_detail_state.dart';
import 'package:africaonlinestores/features/shorts/feeds/repository/short_feed_repository.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_engagement_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_library_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_report_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_share_api.dart';
import 'package:africaonlinestores/features/shorts/shared/data/api/shorts_tracking_api.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:share_plus/share_plus.dart';

class ShortDetailController extends StateNotifier<ShortDetailState> {
  static const int _loadMoreThreshold = 2;

  final ShortsRepository _repository;
  final ShortsEngagementApi _engagementApi;
  final ShortsTrackingApi _trackingApi;
  final ShortsShareApi _shareApi;
  final ShortsLibraryApi _libraryApi;
  final ShortsReportApi _reportApi;
  final ApiClient _apiClient;

  final String _sessionId = 'shorts_${DateTime.now().microsecondsSinceEpoch}';
  final Set<String> _impressedShortIds = <String>{};
  final Map<String, int> _lastTrackedWatchMs = <String, int>{};

  ShortDetailController({
    required ShortDetailArgs args,
    required ShortsRepository repository,
    required ShortsEngagementApi engagementApi,
    required ShortsTrackingApi trackingApi,
    required ShortsShareApi shareApi,
    required ShortsLibraryApi libraryApi,
    required ShortsReportApi reportApi,
    required ApiClient apiClient,
  }) : _repository = repository,
       _engagementApi = engagementApi,
       _trackingApi = trackingApi,
       _shareApi = shareApi,
       _libraryApi = libraryApi,
       _reportApi = reportApi,
       _apiClient = apiClient,
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
      final page = await _repository.fetchForYou(cursor: state.nextCursor);

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

  Future<void> toggleSave(String shortId) async {
    if (state.pendingSaveIds.contains(shortId)) return;

    final index = state.items.indexWhere((short) => short.id.value == shortId);
    if (index == -1) return;

    final originalShort = state.items[index];
    final wasSaved = originalShort.viewerState.isSaved;

    final optimisticShort = originalShort.copyWith(
      metrics: originalShort.metrics.copyWith(
        saveCount: wasSaved
            ? (originalShort.metrics.saveCount - 1).clamp(0, 1 << 31)
            : originalShort.metrics.saveCount + 1,
      ),
      viewerState: originalShort.viewerState.copyWith(isSaved: !wasSaved),
    );

    _replaceShortAt(
      index,
      optimisticShort,
      pendingSaveIds: {...state.pendingSaveIds, shortId},
    );

    final result = await _engagementApi.toggleSave(shortId: shortId);

    result.fold(
      (failure) {
        debugPrint('Toggle save failed: ${failure.message}');

        final updatedPending = {...state.pendingSaveIds}..remove(shortId);
        final rollbackIndex = state.items.indexWhere(
          (short) => short.id.value == shortId,
        );

        if (rollbackIndex == -1) {
          state = state.copyWith(
            pendingSaveIds: updatedPending,
            errorMessage: failure.message,
          );
          return;
        }

        _replaceShortAt(
          rollbackIndex,
          originalShort,
          pendingSaveIds: updatedPending,
        );

        state = state.copyWith(errorMessage: failure.message);
      },
      (toggleResult) {
        final updatedPending = {...state.pendingSaveIds}..remove(shortId);
        final syncIndex = state.items.indexWhere(
          (short) => short.id.value == toggleResult.shortId,
        );

        if (syncIndex == -1) {
          state = state.copyWith(pendingSaveIds: updatedPending);
          return;
        }

        final currentShort = state.items[syncIndex];
        final syncedShort = currentShort.copyWith(
          metrics: currentShort.metrics.copyWith(
            saveCount: toggleResult.saveCount ?? currentShort.metrics.saveCount,
          ),
          viewerState: currentShort.viewerState.copyWith(
            isSaved: toggleResult.saved,
          ),
        );

        _replaceShortAt(syncIndex, syncedShort, pendingSaveIds: updatedPending);
      },
    );
  }

  Future<void> toggleRepost(String shortId, {String? note}) async {
    if (state.pendingRepostIds.contains(shortId)) return;

    final index = state.items.indexWhere((short) => short.id.value == shortId);
    if (index == -1) return;

    final original = state.items[index];
    if (!original.canRepost && !original.isReposted) {
      state = state.copyWith(errorMessage: 'This short cannot be reposted.');
      return;
    }

    state = state.copyWith(
      pendingRepostIds: {...state.pendingRepostIds, shortId},
      errorMessage: null,
    );

    final result = await _engagementApi.toggleRepost(
      shortId: shortId,
      note: note,
    );

    result.fold(
      (failure) {
        final pending = {...state.pendingRepostIds}..remove(shortId);
        state = state.copyWith(
          pendingRepostIds: pending,
          errorMessage: failure.message,
        );
      },
      (toggleResult) {
        final pending = {...state.pendingRepostIds}..remove(shortId);
        final syncIndex = state.items.indexWhere(
          (short) => short.id.value == toggleResult.shortId,
        );
        if (syncIndex == -1) {
          state = state.copyWith(pendingRepostIds: pending);
          return;
        }

        final current = state.items[syncIndex];
        _replaceShortAt(
          syncIndex,
          current.copyWith(
            metrics: current.metrics.copyWith(
              repostCount:
                  toggleResult.repostCount ?? current.metrics.repostCount,
              shareCount: toggleResult.shareCount ?? current.metrics.shareCount,
            ),
            viewerState: current.viewerState.copyWith(
              isReposted: toggleResult.reposted,
            ),
          ),
          pendingRepostIds: pending,
        );
      },
    );
  }

  Future<void> shareShort(String shortId) async {
    if (state.pendingShareIds.contains(shortId)) return;

    final index = state.items.indexWhere((short) => short.id.value == shortId);
    if (index == -1) return;

    final short = state.items[index];
    state = state.copyWith(
      pendingShareIds: {...state.pendingShareIds, shortId},
    );

    final result = await _shareApi.createShareLink(
      shortId: shortId,
      sessionId: _sessionId,
    );

    await result.fold(
      (failure) async {
        final updatedPending = {...state.pendingShareIds}..remove(shortId);
        state = state.copyWith(
          pendingShareIds: updatedPending,
          errorMessage: failure.message,
        );
      },
      (shareResult) async {
        final updatedPending = {...state.pendingShareIds}..remove(shortId);
        final syncIndex = state.items.indexWhere(
          (item) => item.id.value == shareResult.shortId,
        );

        if (syncIndex != -1) {
          final current = state.items[syncIndex];
          _replaceShortAt(
            syncIndex,
            current.copyWith(
              metrics: current.metrics.copyWith(
                shareCount:
                    shareResult.shareCount ?? current.metrics.shareCount + 1,
              ),
            ),
            pendingShareIds: updatedPending,
          );
        } else {
          state = state.copyWith(pendingShareIds: updatedPending);
        }

        try {
          await SharePlus.instance.share(
            ShareParams(
              title: 'Share short',
              subject: 'Check out this short',
              text: _buildShareText(short, shareResult.shareUrl),
            ),
          );
        } catch (e) {
          debugPrint('Open share intent failed: $e');
          state = state.copyWith(errorMessage: 'Unable to open share options.');
        }
      },
    );
  }

  Future<void> downloadShort(String shortId) async {
    if (state.pendingDownloadIds.contains(shortId)) return;

    final index = state.items.indexWhere((short) => short.id.value == shortId);
    if (index == -1) return;

    state = state.copyWith(
      pendingDownloadIds: {...state.pendingDownloadIds, shortId},
      errorMessage: null,
    );

    final result = await _libraryApi.downloadShort(
      shortId: shortId,
      sessionId: _sessionId,
    );

    await result.fold(
      (failure) async {
        final updatedPending = {...state.pendingDownloadIds}..remove(shortId);
        state = state.copyWith(
          pendingDownloadIds: updatedPending,
          errorMessage: failure.message,
        );
      },
      (download) async {
        File? tempFile;
        try {
          tempFile = File(
            '${Directory.systemTemp.path}${Platform.pathSeparator}'
            'aos_short_${shortId}_${DateTime.now().microsecondsSinceEpoch}.mp4',
          );

          await _apiClient.dio.download(
            download.downloadUrl,
            tempFile.path,
            options: Options(
              followRedirects: true,
              receiveTimeout: const Duration(seconds: 90),
              sendTimeout: const Duration(seconds: 15),
              headers: const {'Accept': 'video/*,*/*;q=0.8'},
            ),
          );

          if (!tempFile.existsSync()) {
            throw const FileSystemException(
              'Temporary short file was not created.',
            );
          }

          final short = state.items.firstWhere(
            (item) => item.id.value == shortId,
          );

          await SharePlus.instance.share(
            ShareParams(
              title: 'Save or share short',
              subject: 'AOS Short',
              text: short.caption.toString().trim().isEmpty
                  ? 'AOS Short'
                  : short.caption.toString().trim(),
              files: [XFile(tempFile.path, mimeType: 'video/mp4')],
            ),
          );

          final updatedPending = {...state.pendingDownloadIds}..remove(shortId);
          final syncIndex = state.items.indexWhere(
            (item) => item.id.value == shortId,
          );
          if (syncIndex != -1) {
            final current = state.items[syncIndex];
            _replaceShortAt(
              syncIndex,
              current.copyWith(
                metrics: current.metrics.copyWith(
                  downloadCount:
                      download.downloadCount ??
                      current.metrics.downloadCount + 1,
                ),
              ),
              pendingDownloadIds: updatedPending,
            );
          } else {
            state = state.copyWith(pendingDownloadIds: updatedPending);
          }
        } catch (e) {
          debugPrint('Short download/export failed: $e');
          final updatedPending = {...state.pendingDownloadIds}..remove(shortId);
          state = state.copyWith(
            pendingDownloadIds: updatedPending,
            errorMessage: 'Unable to prepare short download.',
          );
        }
      },
    );
  }

  Future<String?> reportShort({
    required String shortId,
    required String reason,
    required String details,
  }) async {
    final result = await _reportApi.reportShort(
      shortId: shortId,
      reason: reason,
      details: details,
    );

    return result.fold((failure) => failure.message, (_) => null);
  }

  void trackImpression(String shortId) {
    if (_impressedShortIds.contains(shortId)) return;
    _impressedShortIds.add(shortId);

    unawaited(
      _trackingApi.trackImpression(shortId: shortId, sessionId: _sessionId),
    );
  }

  void trackWatchProgress({
    required String shortId,
    required int watchMs,
    bool force = false,
  }) {
    if (watchMs < 500) return;

    final previous = _lastTrackedWatchMs[shortId] ?? 0;
    final delta = watchMs - previous;

    if (delta <= 0) return;

    final shouldSend = force ? delta >= 500 : watchMs >= 2000 && delta >= 5000;

    if (!shouldSend) return;

    _lastTrackedWatchMs[shortId] = watchMs;

    unawaited(
      _trackingApi.trackView(
        shortId: shortId,
        watchMs: watchMs,
        sessionId: _sessionId,
      ),
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

  void removeShort(String shortId) {
    state = state.copyWith(
      items: List.unmodifiable(
        state.items.where((short) => short.id.value != shortId).toList(),
      ),
    );
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
    Set<String>? pendingSaveIds,
    Set<String>? pendingRepostIds,
    Set<String>? pendingShareIds,
    Set<String>? pendingDownloadIds,
  }) {
    if (index < 0 || index >= state.items.length) return;

    final updatedItems = [...state.items];
    updatedItems[index] = updatedShort;

    state = state.copyWith(
      items: List.unmodifiable(updatedItems),
      pendingLikeIds: pendingLikeIds,
      pendingSaveIds: pendingSaveIds,
      pendingRepostIds: pendingRepostIds,
      pendingShareIds: pendingShareIds,
      pendingDownloadIds: pendingDownloadIds,
    );
  }

  String _buildShareText(Short short, String shareUrl) {
    final title = short.caption.toString().trim();
    final buffer = StringBuffer();

    if (title.isNotEmpty) {
      buffer.writeln(title);
      buffer.writeln();
    }

    buffer.writeln('Check out this short on AOS');
    buffer.writeln(shareUrl);

    return buffer.toString().trim();
  }
}
