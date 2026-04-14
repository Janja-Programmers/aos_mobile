import 'package:flutter/material.dart';

class ChatQuickReplies extends StatelessWidget {
  final List<String> replies;
  final ValueChanged<String> onTap;

  const ChatQuickReplies({
    super.key,
    required this.replies,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (replies.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: replies.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final text = replies[index];

          return ActionChip(
            label: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
            onPressed: () => onTap(text),
          );
        },
      ),
    );
  }
}
