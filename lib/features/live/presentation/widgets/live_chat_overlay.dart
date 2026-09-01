import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/live/comments/live_comment.dart';
import 'package:africaonlinestores/features/live/presentation/live_l10n.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/components/app_circle_avatar.dart';
import 'package:africaonlinestores/shared/components/verified_badge.dart';
import 'package:flutter/material.dart';

class LiveChatOverlay extends StatefulWidget {
  const LiveChatOverlay({
    super.key,
    required this.comments,
    required this.onReply,
    required this.onOpenProfile,
    required this.canDelete,
    required this.onDelete,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.onLoadMore,
  });

  final List<LiveComment> comments;
  final ValueChanged<LiveComment> onReply;
  final ValueChanged<String> onOpenProfile;
  final bool Function(LiveComment comment) canDelete;
  final ValueChanged<LiveComment> onDelete;
  final bool hasMore;
  final bool isLoadingMore;
  final Future<void> Function()? onLoadMore;

  @override
  State<LiveChatOverlay> createState() => _LiveChatOverlayState();
}

class _LiveChatOverlayState extends State<LiveChatOverlay> {
  final ScrollController _controller = ScrollController();
  bool _loadQueued = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients ||
        _loadQueued ||
        !widget.hasMore ||
        widget.isLoadingMore ||
        widget.onLoadMore == null) {
      return;
    }
    if (_controller.position.extentAfter > 120) return;
    _loadQueued = true;
    unawaited(
      widget.onLoadMore!().whenComplete(() {
        if (mounted) _loadQueued = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final height = (media.size.height * .34).clamp(180.0, 360.0).toDouble();
    return SizedBox(
      height: height,
      child: ListView.builder(
        controller: _controller,
        reverse: true,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 10, 8),
        itemCount: widget.comments.length + (widget.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == widget.comments.length) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          final comment = widget.comments[index];
          return comment.isSystem
              ? _SystemMessage(comment: comment)
              : _UserMessage(
                  comment: comment,
                  canDelete: widget.canDelete(comment),
                  onReply: () => widget.onReply(comment),
                  onDelete: () => widget.onDelete(comment),
                  onOpenProfile: comment.canOpenProfile
                      ? () => widget.onOpenProfile(comment.userId)
                      : null,
                );
        },
      ),
    );
  }
}

class _SystemMessage extends StatelessWidget {
  const _SystemMessage({required this.comment});

  final LiveComment comment;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: colors.elevated,
            child: Text(
              'A',
              style: AppTextStylesX(context).caption.copyWith(
                color: colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DecoratedBox(
              key: const Key('live_system_message_surface'),
              decoration: BoxDecoration(
                color: colors.black.withValues(alpha: .46),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 7, 10, 7),
                child: Text(
                  comment.comment,
                  style: context.p.copyWith(color: colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserMessage extends StatelessWidget {
  const _UserMessage({
    required this.comment,
    required this.canDelete,
    required this.onReply,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final LiveComment comment;
  final bool canDelete;
  final VoidCallback onReply;
  final VoidCallback onDelete;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final replyName = comment.replyTo?.authorLabel;
    final actionStyle = AppTextStylesX(context).caption.copyWith(
      color: colors.white.withValues(alpha: .72),
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: onOpenProfile != null,
            label: comment.authorLabel,
            child: GestureDetector(
              onTap: onOpenProfile,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: AppCircularAvatar(
                  name: comment.authorLabel,
                  imageUrl: comment.avatarUrl,
                  radius: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DecoratedBox(
              key: Key('live_message_surface_${comment.id}'),
              decoration: BoxDecoration(
                color: colors.black.withValues(alpha: .52),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: colors.white.withValues(alpha: .08)),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(6, 5, 4, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: onOpenProfile,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              comment.authorLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.pStrong.copyWith(
                                color: colors.white,
                              ),
                            ),
                          ),
                          if (comment.isVerified) ...[
                            const SizedBox(width: 4),
                            const VerifiedBadge(size: 14),
                          ],
                        ],
                      ),
                    ),
                    if (comment.isReply && replyName != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        context.l10n.liveReplyingTo(replyName),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStylesX(context).caption.copyWith(
                          color: colors.white.withValues(alpha: .68),
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const SizedBox(height: 1),
                    Text(
                      comment.comment,
                      style: context.p.copyWith(color: colors.white),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          key: Key('live_reply_${comment.id}'),
                          style: TextButton.styleFrom(
                            minimumSize: const Size(44, 34),
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: onReply,
                          child: Text(
                            context.l10n.liveReply,
                            style: actionStyle,
                          ),
                        ),
                        if (canDelete) ...[
                          const SizedBox(width: 2),
                          IconButton(
                            key: Key('live_delete_${comment.id}'),
                            tooltip: context.l10n.liveDeleteComment,
                            onPressed: onDelete,
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 16,
                            ),
                            color: colors.white.withValues(alpha: .68),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 34,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
