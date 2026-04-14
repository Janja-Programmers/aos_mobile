import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_attachment.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/attachments/attachment_opener.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/attachments/viewers/inline_audio_player.dart';

class AttachmentGrid extends StatelessWidget {
  final List<ChatAttachment> attachments;

  const AttachmentGrid({super.key, required this.attachments});

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: attachments.map((att) {
        return _buildAttachment(context, att);
      }).toList(),
    );
  }

  Widget _buildAttachment(BuildContext context, ChatAttachment att) {
    final url = buildFileUrl(att.url);
    if (url == null) return const SizedBox();

    switch (att.type) {
      // -----------------------------
      // IMAGE
      // -----------------------------
      case 'image':
        return GestureDetector(
          onTap: () =>
              AttachmentOpener.open(context: context, type: att.type, url: url),
          child: _image(url),
        );

      // -----------------------------
      // VIDEO
      // -----------------------------
      case 'video':
        return GestureDetector(
          onTap: () =>
              AttachmentOpener.open(context: context, type: att.type, url: url),
          child: _video(),
        );

      // -----------------------------
      // AUDIO (INLINE 🔥)
      // -----------------------------
      case 'audio':
        return InlineAudioPlayer(url: url);

      // -----------------------------
      // DOCUMENT (IMPORTANT 🔥)
      // -----------------------------
      case 'document':
      default:
        return GestureDetector(
          onTap: () =>
              AttachmentOpener.open(context: context, type: att.type, url: url),
          child: _document(),
        );
    }
  }

  // -----------------------------
  // IMAGE
  // -----------------------------
  Widget _image(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallback(Icons.image),
      ),
    );
  }

  // -----------------------------
  // VIDEO
  // -----------------------------
  Widget _video() {
    return _stackBox(Icons.play_circle_fill);
  }

  // -----------------------------
  // DOCUMENT
  // -----------------------------
  Widget _document() {
    return _fileBox(Icons.insert_drive_file, "Doc");
  }

  // -----------------------------
  // COMMON UI
  // -----------------------------
  Widget _stackBox(IconData icon) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        Icon(icon, size: 40),
      ],
    );
  }

  Widget _fileBox(IconData icon, String label) {
    return Container(
      width: 120,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _fallback(IconData icon) {
    return Container(
      width: 120,
      height: 120,
      alignment: Alignment.center,
      color: Colors.grey.shade300,
      child: Icon(icon),
    );
  }
}
