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
    required this.onContact,
  });

  final VoidCallback onGallery;
  final VoidCallback onCamera;
  final VoidCallback onDocument;
  final VoidCallback onLocation;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: colors.border)),
          boxShadow: [
            BoxShadow(
              color: colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 24,
                runSpacing: 26,
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
                    icon: Icons.location_on_rounded,
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
                  _Item(
                    icon: Icons.person_rounded,
                    label: 'Contact',
                    color: colors.orange,
                    onTap: onContact,
                  ),
                ],
              ),
            ],
          ),
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
        width: 82,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.24),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, size: 30, color: colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.p.copyWith(
                fontSize: 13,
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
