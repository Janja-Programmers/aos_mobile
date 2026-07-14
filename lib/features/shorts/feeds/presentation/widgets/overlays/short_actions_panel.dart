import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/controllers/short_session_controller.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/components/feed_avatar_image.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/overlays/comment_sheet.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/overlays/report_short_sheet.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShortActionsPanel extends ConsumerWidget {
  const ShortActionsPanel({
    super.key,
    required this.short,
    required this.onToggleLike,
    required this.onCommentAdded,
    required this.onCreatorTap,
    required this.onShare,
    required this.onSave,
    required this.onRepost,
    required this.onDownload,
    required this.onReport,
    this.onToggleFollow,
    this.isLikedPending = false,
    this.isFollowPending = false,
    this.isSaved = false,
    this.isSavePending = false,
    this.isRepostPending = false,
    this.isSharePending = false,
    this.isDownloadPending = false,
    this.playbackSpeed = 1.0,
    this.onPlaybackSpeedChanged,
    this.onEditShort,
    this.onViewAnalytics,
  });

  final Short short;
  final bool isLikedPending;
  final bool isFollowPending;
  final bool isSaved;
  final bool isSavePending;
  final bool isRepostPending;
  final bool isSharePending;
  final bool isDownloadPending;
  final double playbackSpeed;
  final ValueChanged<double>? onPlaybackSpeedChanged;
  final VoidCallback? onEditShort;
  final VoidCallback? onViewAnalytics;
  final Future<void> Function(String shortId) onToggleLike;
  final void Function(String shortId) onCommentAdded;
  final Future<void> Function(String targetUser)? onToggleFollow;
  final VoidCallback onCreatorTap;
  final Future<void> Function() onShare;
  final Future<void> Function() onSave;
  final Future<void> Function() onRepost;
  final Future<void> Function() onDownload;
  final Future<String?> Function({
    required String shortId,
    required String reason,
    required String details,
  })
  onReport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final metrics = short.metrics;
    const separator = SizedBox(height: 4);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CreatorAvatarAction(
          short: short,
          isFollowPending: isFollowPending,
          onCreatorTap: onCreatorTap,
          onToggleFollow: onToggleFollow,
        ),
        separator,
        _iconWithLabel(
          context,
          icon: short.isLiked
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          color: short.isLiked ? colors.primary : colors.white,
          label: _formatCount(metrics.likeCount),
          semanticLabel: short.isLiked ? 'Unlike' : 'Like',
          isDisabled: isLikedPending,
          onTap: isLikedPending
              ? null
              : () => unawaited(onToggleLike(short.id.value)),
        ),
        separator,
        _iconWithLabel(
          context,
          icon: Icons.mode_comment_outlined,
          color: colors.white,
          label: _formatCount(metrics.commentCount),
          semanticLabel: 'Comments',
          onTap: short.allowComments ? () => _openComments(context, ref) : null,
        ),
        separator,
        if (short.canRepost || short.isReposted) ...[
          _iconWithLabel(
            context,
            icon: Icons.repeat_rounded,
            color: short.isReposted ? colors.primary : colors.white,
            label: _formatCount(metrics.repostCount),
            semanticLabel: short.isReposted ? 'Remove repost' : 'Repost',
            isDisabled: isRepostPending,
            onTap: isRepostPending ? null : () => unawaited(onRepost()),
          ),
          separator,
        ],
        _iconWithLabel(
          context,
          icon: Icons.share_outlined,
          color: colors.white,
          label: _formatCount(metrics.shareCount),
          semanticLabel: 'Share short',
          isDisabled: isSharePending,
          onTap: isSharePending ? null : () => unawaited(onShare()),
        ),
        separator,
        if (short.isOwner)
          _iconWithLabel(
            context,
            icon: Icons.more_vert_rounded,
            color: colors.white,
            label: 'Manage',
            semanticLabel: 'Owner short actions',
            onTap: () => showShortActionsSheet(
              context: context,
              short: short,
              isSaved: isSaved,
              isSavePending: isSavePending,
              isRepostPending: isRepostPending,
              isSharePending: isSharePending,
              isDownloadPending: isDownloadPending,
              onSave: onSave,
              onRepost: onRepost,
              onShare: onShare,
              onDownload: onDownload,
              onReport: onReport,
              playbackSpeed: playbackSpeed,
              onPlaybackSpeedChanged: onPlaybackSpeedChanged,
              onEditShort: onEditShort,
              onViewAnalytics: onViewAnalytics,
            ),
          ),
      ],
    );
  }

  void _openComments(BuildContext context, WidgetRef ref) {
    ref.read(shortSessionControllerProvider.notifier).pause();
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => CommentsSheet(
          short: short,
          onCommentAdded: () => onCommentAdded(short.id.value),
        ),
      ).whenComplete(
        () => ref.read(shortSessionControllerProvider.notifier).resume(),
      ),
    );
  }

  Widget _iconWithLabel(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String semanticLabel,
    required Color color,
    VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return Opacity(
      opacity: isDisabled ? .55 : 1,
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkResponse(
              onTap: onTap,
              radius: 28,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Icon(icon, color: color, size: 30),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: context.appColors.white,
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
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }
}

Future<void> showShortActionsSheet({
  required BuildContext context,
  required Short short,
  required bool isSaved,
  required bool isSavePending,
  required bool isRepostPending,
  required bool isSharePending,
  required bool isDownloadPending,
  required Future<void> Function() onSave,
  required Future<void> Function() onRepost,
  required Future<void> Function() onShare,
  required Future<void> Function() onDownload,
  required Future<String?> Function({
    required String shortId,
    required String reason,
    required String details,
  })
  onReport,
  double playbackSpeed = 1.0,
  ValueChanged<double>? onPlaybackSpeedChanged,
  VoidCallback? onEditShort,
  VoidCallback? onViewAnalytics,
}) async {
  final colors = context.appColors;
  final canDownload = short.allowDownloads || short.isOwner;

  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: colors.surface,
    builder: (sheetContext) {
      Future<void> run(Future<void> Function() action) async {
        Navigator.pop(sheetContext);
        await action();
      }

      return Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16 + MediaQuery.paddingOf(sheetContext).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    label: isSaved ? 'Saved' : 'Save',
                    selected: isSaved,
                    enabled: !isSavePending,
                    onTap: () => unawaited(run(onSave)),
                  ),
                ),
                if (short.canRepost || short.isReposted)
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.repeat_rounded,
                      label: short.isReposted ? 'Reposted' : 'Repost',
                      selected: short.isReposted,
                      enabled: !isRepostPending,
                      onTap: () => unawaited(run(onRepost)),
                    ),
                  ),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    enabled: !isSharePending,
                    onTap: () => unawaited(run(onShare)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SheetAction(
              icon: Icons.speed_rounded,
              title: 'Playback speed',
              subtitle:
                  '${playbackSpeed.toStringAsFixed(playbackSpeed == 1 ? 0 : 2)}×',
              enabled: onPlaybackSpeedChanged != null,
              onTap: () {
                Navigator.pop(sheetContext);
                _showPlaybackSpeedSheet(
                  context: context,
                  selected: playbackSpeed,
                  onSelected: onPlaybackSpeedChanged,
                );
              },
            ),
            _SheetAction(
              icon: Icons.download_outlined,
              title: canDownload ? 'Download' : 'Downloads disabled',
              subtitle: canDownload
                  ? 'Save or export the original video'
                  : 'The creator has disabled downloads',
              enabled: canDownload && !isDownloadPending,
              onTap: () => unawaited(run(onDownload)),
            ),
            if (short.canReport)
              _SheetAction(
                icon: Icons.flag_outlined,
                title: 'Report',
                subtitle: 'Tell us why this short should be reviewed',
                enabled: true,
                onTap: () {
                  Navigator.pop(sheetContext);
                  unawaited(
                    showReportShortSheet(
                      context: context,
                      shortId: short.id.value,
                      onSubmit: onReport,
                    ),
                  );
                },
              ),
            if (short.isOwner) ...[
              _SheetAction(
                icon: Icons.edit_outlined,
                title: short.canEdit ? 'Edit short' : 'Editing unavailable',
                subtitle: short.canEdit
                    ? 'Update permitted short metadata'
                    : 'This short cannot be edited in its current state',
                enabled: short.canEdit && onEditShort != null,
                onTap: () {
                  Navigator.pop(sheetContext);
                  onEditShort?.call();
                },
              ),
              _SheetAction(
                icon: Icons.analytics_outlined,
                title: 'View analytics',
                subtitle: 'Open performance insights for this short',
                enabled: onViewAnalytics != null,
                onTap: () {
                  Navigator.pop(sheetContext);
                  onViewAnalytics?.call();
                },
              ),
            ],
          ],
        ),
      );
    },
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Opacity(
      opacity: enabled ? 1 : .5,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: selected
                    ? colors.primary.withValues(alpha: .14)
                    : colors.elevated,
                child: Icon(
                  icon,
                  color: selected ? colors.primary : colors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(label, style: context.small),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ListTile(
      enabled: enabled,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: colors.primary.withValues(alpha: .10),
        child: Icon(icon, color: colors.primary),
      ),
      title: Text(title, style: context.pStrong),
      subtitle: Text(
        subtitle,
        style: context.small.copyWith(color: colors.textMuted),
      ),
      onTap: enabled ? onTap : null,
    );
  }
}

class _CreatorAvatarAction extends StatelessWidget {
  const _CreatorAvatarAction({
    required this.short,
    required this.isFollowPending,
    required this.onCreatorTap,
    required this.onToggleFollow,
  });

  final Short short;
  final bool isFollowPending;
  final VoidCallback? onCreatorTap;
  final Future<void> Function(String targetUser)? onToggleFollow;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final targetUser = short.viewerState.targetUser ?? short.creator.user;
    final isSelf = short.viewerState.isSelf;
    final isFollowing = short.viewerState.isFollowing;

    return SizedBox(
      width: 56,
      height: 66,
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
                border: Border.all(
                  color: short.creator.isLive ? colors.primary : colors.white,
                  width: short.creator.isLive ? 3 : 2,
                ),
                color: Colors.black54,
              ),
              clipBehavior: Clip.antiAlias,
              child: FeedAvatarImage(
                avatar: buildFileUrl(short.creator.avatar),
                fallbackText: short.creator.displayName,
              ),
            ),
          ),
          if (short.creator.isLive)
            Positioned(
              top: 43,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'LIVE',
                  style: TextStyle(
                    color: colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            )
          else if (!isSelf)
            Positioned(
              bottom: 2,
              child: GestureDetector(
                onTap: isFollowPending || onToggleFollow == null
                    ? null
                    : () => unawaited(onToggleFollow!(targetUser)),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: isFollowing ? colors.primary : colors.white,
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
        ],
      ),
    );
  }
}

Future<void> _showPlaybackSpeedSheet({
  required BuildContext context,
  required double selected,
  required ValueChanged<double>? onSelected,
}) async {
  if (onSelected == null) return;
  const speeds = <double>[0.5, 0.75, 1, 1.25, 1.5, 2];
  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) => RadioGroup<double>(
      groupValue: selected,
      onChanged: (value) {
        if (value == null) return;
        Navigator.pop(sheetContext);
        onSelected(value);
      },
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          const ListTile(title: Text('Playback speed')),
          for (final speed in speeds)
            RadioListTile<double>(
              value: speed,
              title: Text('${speed.toStringAsFixed(speed == 1 ? 0 : 2)}×'),
            ),
        ],
      ),
    ),
  );
}
