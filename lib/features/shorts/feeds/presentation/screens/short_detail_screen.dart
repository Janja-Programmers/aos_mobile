import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/short_detail_state.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/video/short_video_page.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

import 'package:africaonlinestores/features/social/navigation/social_navigation.dart';

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

          return ShortVideoPage(
            key: ValueKey(shortId),
            short: short,
            isActive: index == state.currentIndex,
            shouldPrepare: controller.shouldPrepareVideo(index),

            // Like
            isLikedPending: state.pendingLikeIds.contains(shortId),
            onToggleLike: controller.toggleLike,

            // Comment
            onCommentAdded: controller.incrementCommentCount,

            // Creator / seller
            onCreatorTap: () {
              SocialNavigation.toProfileScreen(context, user: short.sellerId);
            },

            // Follow
            isFollowPending: state.pendingFollowUserIds.contains(targetUser),
            onToggleFollow: controller.toggleFollow,

            // Share
            isSharePending: state.pendingShareIds.contains(shortId),
            onShare: controller.shareShort,

            // Save
            isSaved: short.viewerState.isSaved,
            isSavePending: state.pendingSaveIds.contains(shortId),
            onSave: controller.toggleSave,

            // Download / Report / Tracking
            isDownloadPending: state.pendingDownloadIds.contains(shortId),
            onDownload: controller.downloadShort,
            onReport: controller.reportShort,
            onImpression: controller.trackImpression,
            onWatchProgress: controller.trackWatchProgress,
          );
        },
      ),
    );
  }
}
