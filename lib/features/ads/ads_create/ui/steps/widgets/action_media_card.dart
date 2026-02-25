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

class AddMoreCard extends StatelessWidget {
  final VoidCallback? onTakePhoto;
  final VoidCallback? onUploadPhoto;

  const AddMoreCard({super.key, this.onTakePhoto, this.onUploadPhoto});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTakePhoto,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: context.appColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: GestureDetector(
              onTap: onUploadPhoto,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    Icons.photo_library_outlined,
                    color: context.appColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
