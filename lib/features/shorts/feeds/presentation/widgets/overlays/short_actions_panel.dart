import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/shorts/feeds/application/controllers/short_session_controller.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/components/feed_avatar_image.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/overlays/comment_sheet.dart';

import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';

class ShortActionsPanel extends ConsumerWidget {
  final Short short;

  final bool isLikedPending;
  final bool isFollowPending;
  final bool isSaved;
  final bool isSavePending;

  final Future<void> Function(String shortId) onToggleLike;
  final void Function(String shortId) onCommentAdded;
  final Future<void> Function(String targetUser)? onToggleFollow;
  final VoidCallback onCreatorTap;
  final Future<void> Function() onShare;
  final Future<void> Function() onSave;

  const ShortActionsPanel({
    super.key,
    required this.short,
    required this.onToggleLike,
    required this.onCommentAdded,
    required this.onCreatorTap,
    required this.onShare,
    required this.onSave,
    this.onToggleFollow,
    this.isLikedPending = false,
    this.isFollowPending = false,
    this.isSaved = false,
    this.isSavePending = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    final isLiked = short.isLiked;
    final metrics = short.metrics;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CreatorAvatarAction(
          short: short,
          isFollowPending: isFollowPending,
          onCreatorTap: onCreatorTap,
          onToggleFollow: onToggleFollow,
        ),

        const SizedBox(height: 18),

        _iconWithLabel(
          context,
          icon: isLiked
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          color: isLiked ? colors.primary : colors.white,
          label: _formatCount(metrics.likeCount),
          isDisabled: isLikedPending,
          semanticLabel: isLiked ? 'Unlike' : 'Like',
          onTap: isLikedPending
              ? null
              : () {
                  onToggleLike(short.id.value);
                },
        ),

        const SizedBox(height: 18),

        _iconWithLabel(
          context,
          icon: Icons.mode_comment_outlined,
          color: colors.white,
          label: _formatCount(metrics.commentCount),
          semanticLabel: 'Comments',
          onTap: () {
            ref.read(shortSessionControllerProvider.notifier).pause();

            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (_) => CommentsSheet(
                short: short,
                onCommentAdded: () {
                  onCommentAdded(short.id.value);
                },
              ),
            ).whenComplete(() {
              ref.read(shortSessionControllerProvider.notifier).resume();
            });
          },
        ),

        const SizedBox(height: 18),

        _iconWithLabel(
          context,
          icon: isSaved
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          color: isSaved ? colors.primary : colors.white,
          label: _formatCount(metrics.saveCount),
          isDisabled: isSavePending,
          semanticLabel: isSaved ? 'Unsave short' : 'Save short',
          onTap: isSavePending ? null : onSave,
        ),

        const SizedBox(height: 18),

        _iconWithLabel(
          context,
          iconWidget: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..scale(-1.0, 1.0),
            child: Icon(Icons.reply_outlined, color: colors.white, size: 34),
          ),
          label: _formatCount(metrics.shareCount),
          semanticLabel: 'Share short',
          onTap: onShare,
        ),
      ],
    );
  }

  Widget _iconWithLabel(
    BuildContext context, {
    IconData? icon,
    Widget? iconWidget,
    required String label,
    required String semanticLabel,
    Color? color,
    VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    final colors = context.appColors;

    return Opacity(
      opacity: isDisabled ? 0.55 : 1,
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child:
                    iconWidget ??
                    Icon(icon, color: color ?? colors.white, size: 34),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toString();
  }
}

class _CreatorAvatarAction extends StatelessWidget {
  final Short short;
  final bool isFollowPending;
  final VoidCallback? onCreatorTap;
  final Future<void> Function(String targetUser)? onToggleFollow;

  const _CreatorAvatarAction({
    required this.short,
    required this.isFollowPending,
    required this.onCreatorTap,
    required this.onToggleFollow,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final imageUri = buildFileUrl(short.creator.avatar);
    final avatar = imageUri;

    final targetUser = short.viewerState.targetUser ?? short.creator.user;

    final isSelf = short.viewerState.isSelf;
    final isFollowing = short.viewerState.isFollowing;

    return SizedBox(
      width: 52,
      height: 62,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onCreatorTap,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.white, width: 2),
                color: Colors.black54,
              ),
              clipBehavior: Clip.antiAlias,
              child: FeedAvatarImage(
                avatar: avatar,
                fallbackText: short.creator.displayName,
              ),
            ),
          ),

          if (!isSelf)
            Positioned(
              bottom: 2,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: isFollowPending || onToggleFollow == null
                    ? null
                    : () {
                        onToggleFollow!(targetUser);
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFollowing ? colors.primary : colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: isFollowPending
                      ? Padding(
                          padding: const EdgeInsets.all(5),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isFollowing ? colors.white : colors.primary,
                          ),
                        )
                      : Icon(
                          isFollowing ? Icons.check_rounded : Icons.add_rounded,
                          size: 17,
                          color: isFollowing ? colors.white : colors.black,
                        ),
                ),
              ),
            ),

          if (isSelf)
            Positioned(
              bottom: 2,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 15,
                  color: colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
