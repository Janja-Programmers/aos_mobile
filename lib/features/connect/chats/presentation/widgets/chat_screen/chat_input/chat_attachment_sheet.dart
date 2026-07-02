import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class ChatAttachmentSheet extends StatelessWidget {
  const ChatAttachmentSheet({
    super.key,
    required this.onGallery,
    required this.onCamera,
    required this.onDocument,
    required this.onLocation,
    required this.onFolder,
  });

  final VoidCallback onGallery;
  final VoidCallback onCamera;
  final VoidCallback onDocument;
  final VoidCallback onLocation;
  final VoidCallback onFolder;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Item(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  color: colors.purple,
                  onTap: onGallery,
                ),
                _Item(
                  icon: Icons.photo_camera_outlined,
                  label: 'Camera',
                  color: colors.primary,
                  onTap: onCamera,
                ),
                _Item(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  color: colors.success,
                  onTap: onLocation,
                ),
                _Item(
                  icon: Icons.insert_drive_file_outlined,
                  label: 'Document',
                  color: colors.blue,
                  onTap: onDocument,
                ),
              ],
            ),

            const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor: color.withValues(alpha: 0.14),
              child: Icon(icon, size: 25, color: color),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.p.copyWith(
                fontSize: 12,
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
