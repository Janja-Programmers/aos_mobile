import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:flutter/material.dart';

class ReactionChips extends StatelessWidget {
  const ReactionChips({super.key, required this.message, required this.isMe});

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: isMe ? WrapAlignment.end : WrapAlignment.start,
      children: message.reactions.map((reaction) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: reaction.reactedByMe
                ? colors.primary.withValues(alpha: 0.16)
                : colors.elevated,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: reaction.reactedByMe ? colors.primary : colors.border,
            ),
          ),
          child: Text(
            '${reaction.emoji} ${reaction.count}',
            style: context.p.copyWith(
              fontSize: 12,
              color: isMe ? colors.white : colors.textPrimary,
            ),
          ),
        );
      }).toList(),
    );
  }
}
