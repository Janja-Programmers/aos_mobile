import 'dart:async';

import 'package:africaonlinestores/features/live/navigation/live_routes.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/widgets/edit_short_metadata_sheet.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/short_detail_state.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/video/short_video_page.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:africaonlinestores/features/social/navigation/social_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShortDetailScreen extends ConsumerStatefulWidget {
  final List<Short> initialShorts;
  final int initialIndex;
  final String? initialNextCursor;
  final bool initialHasMore;

  const ShortDetailScreen({
    super.key,
    required this.initialShorts,
    required this.initialIndex,
    required this.initialNextCursor,
    required this.initialHasMore,
  });

  @override
  ConsumerState<ShortDetailScreen> createState() => _ShortDetailScreenState();
}

class _ShortDetailScreenState extends ConsumerState<ShortDetailScreen> {
  late final PageController _pageController;
  late final ShortDetailArgs _args;

  @override
  void initState() {
    super.initState();
    _args = ShortDetailArgs(
      initialShorts: widget.initialShorts,
      initialIndex: widget.initialIndex,
      initialNextCursor: widget.initialNextCursor,
      initialHasMore: widget.initialHasMore,
    );
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shortDetailControllerProvider(_args));
    final controller = ref.read(shortDetailControllerProvider(_args).notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: state.items.length,
        onPageChanged: controller.onPageChanged,
        itemBuilder: (context, index) {
          final short = state.items[index];
          final shortId = short.id.value;
          final targetUser = short.viewerState.targetUser ?? short.creator.user;

          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              ShortVideoPage(
                key: ValueKey(shortId),
                short: short,
                isActive: index == state.currentIndex,
                shouldPrepare: controller.shouldPrepareVideo(index),
                isLikedPending: state.pendingLikeIds.contains(shortId),
                onToggleLike: controller.toggleLike,
                onCommentAdded: controller.incrementCommentCount,
                onCreatorTap: () {
                  final creatorUser = short.creator.user.trim();
                  if (creatorUser.isEmpty) return;
                  final liveId = short.creator.liveId?.trim() ?? '';
                  if (short.creator.isLive && liveId.isNotEmpty) {
                    LiveNavigation.toLiveRoom(context, liveId: liveId);
                    return;
                  }
                  SocialNavigation.toProfileScreen(
                    context,
                    user: creatorUser,
                    displayName: short.creator.displayName,
                    avatar: short.creator.avatar,
                  );
                },
                isFollowPending: state.pendingFollowUserIds.contains(
                  targetUser,
                ),
                onToggleFollow: controller.toggleFollow,
                isRepostPending: state.pendingRepostIds.contains(shortId),
                onRepost: controller.toggleRepost,
                isSharePending: state.pendingShareIds.contains(shortId),
                onShare: controller.shareShort,
                isSaved: short.viewerState.isSaved,
                isSavePending: state.pendingSaveIds.contains(shortId),
                onSave: controller.toggleSave,
                isDownloadPending: state.pendingDownloadIds.contains(shortId),
                onDownload: controller.downloadShort,
                onReport: controller.reportShort,
                onImpression: controller.trackImpression,
                onWatchProgress: controller.trackWatchProgress,
              ),
              if (short.isOwner && short.canEdit)
                PositionedDirectional(
                  top: MediaQuery.paddingOf(context).top + 12,
                  end: 12,
                  child: Semantics(
                    button: true,
                    label: 'Edit Short metadata and sound',
                    child: IconButton.filled(
                      tooltip: 'Edit Short',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => unawaited(_editShort(short)),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editShort(Short short) async {
    final changed = await showEditShortMetadataSheet(context, short: short);
    if (!changed || !mounted) return;
    await ref.read(shortsControllerProvider.notifier).loadInitial();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Short updated.')));
    Navigator.pop(context);
  }
}
