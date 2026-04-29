import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/live/domain/live_chat_message.dart';

class LiveChatOverlay extends StatelessWidget {
  final List<LiveChatMessage> messages;

  const LiveChatOverlay({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final visibleMessages = messages.length > 10
        ? messages.sublist(messages.length - 10)
        : messages;

    return Positioned(
      left: 12,
      right: 80,
      bottom: 120,
      child: SizedBox(
        height: 260,
        child: ListView.builder(
          reverse: true,
          padding: EdgeInsets.zero,
          itemCount: visibleMessages.length,
          itemBuilder: (_, i) {
            final msg = visibleMessages[visibleMessages.length - 1 - i];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: RichText(
                text: TextSpan(
                  children: [
                    // 👤 Username
                    TextSpan(
                      text: "${msg.username}: ",
                      style: context.p.copyWith(
                        color: colors.amber,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // 💬 Message
                    TextSpan(
                      text: msg.message,
                      style: context.p.copyWith(color: colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
