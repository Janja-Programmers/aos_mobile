import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/chats/domain/helpers/chat_pending_attachment.dart';

class AttachmentPreviewBar extends StatelessWidget {
  final List<ChatPendingAttachment> attachments;
  final ValueChanged<int> onRemove;

  const AttachmentPreviewBar({
    super.key,
    required this.attachments,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      height: 76,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: attachments.length,
        itemBuilder: (_, i) {
          final attachment = attachments[i];

          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0, 6, 8, 8),
                width: 66,
                height: 66,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: colors.elevated,
                  border: Border.all(color: colors.border),
                ),
                child: _AttachmentPreview(attachment: attachment),
              ),

              Positioned(
                right: 2,
                top: 2,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onRemove(i),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: colors.black.withOpacity(0.65),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  final ChatPendingAttachment attachment;

  const _AttachmentPreview({required this.attachment});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (attachment.type == 'image') {
      return Image.file(
        attachment.file,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Icon(Icons.broken_image_outlined, color: colors.textMuted);
        },
      );
    }

    if (attachment.type == 'video') {
      return _IconPreview(
        icon: Icons.play_circle_outline_rounded,
        color: colors.primary,
      );
    }

    if (attachment.type == 'audio') {
      return _IconPreview(
        icon: Icons.graphic_eq_rounded,
        color: colors.primary,
      );
    }

    return _IconPreview(
      icon: Icons.insert_drive_file_outlined,
      color: colors.primary,
    );
  }
}

class _IconPreview extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconPreview({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      color: colors.elevated,
      child: Center(child: Icon(icon, color: color, size: 30)),
    );
  }
}
