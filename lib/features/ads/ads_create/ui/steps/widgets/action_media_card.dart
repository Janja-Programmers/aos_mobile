import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

class ActionMediaCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const ActionMediaCard({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: context.appColors.border,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: context.p),
            const SizedBox(width: 8),
            Icon(icon, color: context.appColors.primary, size: 28),
          ],
        ),
      ),
    );
  }
}

class AddPhotoTile extends StatelessWidget {
  final VoidCallback onUpload;
  final VoidCallback onTakePhoto;

  const AddPhotoTile({
    super.key,
    required this.onUpload,
    required this.onTakePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      width: 110,
      height: 110,
      child: GestureDetector(
        onTapDown: (details) async {
          final selected = await showMenu<String>(
            context: context,
            color: colors.white,
            position: RelativeRect.fromLTRB(
              details.globalPosition.dx,
              details.globalPosition.dy,
              details.globalPosition.dx,
              details.globalPosition.dy,
            ),
            items: const [
              PopupMenuItem(
                value: 'upload',
                child: Row(
                  children: [
                    Icon(Icons.photo_library_outlined, size: 20),
                    SizedBox(width: 10),
                    Text('Upload Photos'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'camera',
                child: Row(
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 20),
                    SizedBox(width: 10),
                    Text('Take Photo'),
                  ],
                ),
              ),
            ],
          );

          if (selected == 'upload') onUpload();
          if (selected == 'camera') onTakePhoto();
        },

        child: Container(
          decoration: BoxDecoration(
            color: colors.black.withOpacity(.7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, size: 32, color: colors.white),
                Text("Add", style: context.p.copyWith(color: colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
