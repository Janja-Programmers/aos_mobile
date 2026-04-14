import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/connect/chats/domain/chat_attachment.dart';

class AttachmentGrid extends StatelessWidget {
  final List<ChatAttachment> attachments;

  const AttachmentGrid({super.key, required this.attachments});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: attachments.map((att) {
        return _buildAttachment(att);
      }).toList(),
    );
  }

  Widget _buildAttachment(ChatAttachment att) {
    if (att.type == 'image') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          att.url,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 120,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(att.type.toUpperCase()),
    );
  }
}
