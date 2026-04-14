import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

class ChatAttachmentSheet extends StatelessWidget {
  const ChatAttachmentSheet({
    super.key,
    required this.onImage,
    required this.onDocument,
    required this.onVideo,
  });

  final VoidCallback onImage;
  final VoidCallback onDocument;
  final VoidCallback onVideo;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Item(icon: Icons.image, label: "Image", onTap: onImage),
            _Item(
              icon: Icons.insert_drive_file,
              label: "Document",
              onTap: onDocument,
            ),
            _Item(icon: Icons.videocam, label: "Video", onTap: onVideo),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: colors.primary,
            child: Icon(icon, size: 26, color: colors.surface),
          ),

          const SizedBox(height: 6),
          Text(label, style: context.p),
        ],
      ),
    );
  }
}
