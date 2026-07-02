import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_attachment.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/attachments/attachment_opener.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/attachments/viewers/inline_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AttachmentGrid extends StatelessWidget {
  final List<ChatAttachment> attachments;

  const AttachmentGrid({super.key, required this.attachments});

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    final mediaAttachments = attachments
        .where((attachment) => attachment.isImage || attachment.isVideo)
        .toList();

    final otherAttachments = attachments
        .where((attachment) => !attachment.isImage && !attachment.isVideo)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mediaAttachments.isNotEmpty)
          _MediaAttachmentGrid(attachments: mediaAttachments),
        if (mediaAttachments.isNotEmpty && otherAttachments.isNotEmpty)
          const SizedBox(height: 6),
        ...otherAttachments.map((attachment) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _buildAttachment(context, attachment),
          );
        }),
      ],
    );
  }

  Widget _buildAttachment(BuildContext context, ChatAttachment attachment) {
    final url = buildFileUrl(attachment.url);
    if (url == null) return const SizedBox.shrink();

    if (attachment.isAudio) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260),
        child: InlineAudioPlayer(url: url),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => AttachmentOpener.open(
        context: context,
        type: attachment.type,
        url: url,
      ),
      child: _DocumentAttachment(url: url),
    );
  }
}

class _MediaAttachmentGrid extends StatelessWidget {
  final List<ChatAttachment> attachments;

  const _MediaAttachmentGrid({required this.attachments});

  @override
  Widget build(BuildContext context) {
    final visible = attachments.take(4).toList();
    final extraCount = attachments.length - visible.length;

    if (visible.length == 1) {
      return _MediaTile(
        attachment: visible.first,
        width: 230,
        height: 230,
        borderRadius: BorderRadius.circular(12),
      );
    }

    return SizedBox(
      width: 236,
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: visible.asMap().entries.map((entry) {
          final index = entry.key;
          final attachment = entry.value;
          final showExtraOverlay =
              extraCount > 0 && index == visible.length - 1;

          return _MediaTile(
            attachment: attachment,
            width: 116,
            height: 116,
            borderRadius: BorderRadius.circular(10),
            overlayText: showExtraOverlay ? '+$extraCount' : null,
          );
        }).toList(),
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  final ChatAttachment attachment;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final String? overlayText;

  const _MediaTile({
    required this.attachment,
    required this.width,
    required this.height,
    required this.borderRadius,
    this.overlayText,
  });

  @override
  Widget build(BuildContext context) {
    final url = buildFileUrl(attachment.url);
    final colors = context.appColors;

    if (url == null) return const SizedBox.shrink();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => AttachmentOpener.open(
        context: context,
        type: attachment.type,
        url: url,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: width,
              height: height,
              child: attachment.isImage
                  ? CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          _AttachmentSkeleton(width: width, height: height),
                      errorWidget: (_, _, _) => _AttachmentFallback(
                        width: width,
                        height: height,
                        icon: Icons.image_not_supported_outlined,
                      ),
                    )
                  : _VideoPlaceholder(width: width, height: height),
            ),
            if (attachment.isVideo)
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.black.withValues(alpha: 0.46),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: colors.white,
                  size: 34,
                ),
              ),
            if (overlayText != null)
              Positioned.fill(
                child: Container(
                  color: colors.black.withValues(alpha: 0.58),
                  alignment: Alignment.center,
                  child: Text(
                    overlayText!,
                    style: TextStyle(
                      color: colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  final double width;
  final double height;

  const _VideoPlaceholder({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.black.withValues(alpha: 0.70),
            colors.black.withValues(alpha: 0.40),
          ],
        ),
      ),
      child: Icon(
        Icons.videocam_rounded,
        color: colors.white.withValues(alpha: 0.80),
        size: 30,
      ),
    );
  }
}

class _DocumentAttachment extends StatelessWidget {
  final String url;

  const _DocumentAttachment({required this.url});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fileName = Uri.tryParse(url)?.pathSegments.last ?? 'Document';

    return Container(
      width: 236,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.insert_drive_file_rounded,
              color: colors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tap to open',
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentSkeleton extends StatelessWidget {
  final double width;
  final double height;

  const _AttachmentSkeleton({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: colors.elevated),
      alignment: Alignment.center,
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: colors.textMuted,
        ),
      ),
    );
  }
}

class _AttachmentFallback extends StatelessWidget {
  final double width;
  final double height;
  final IconData icon;

  const _AttachmentFallback({
    required this.width,
    required this.height,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: width,
      height: height,
      color: colors.elevated,
      alignment: Alignment.center,
      child: Icon(icon, color: colors.textMuted, size: 30),
    );
  }
}
