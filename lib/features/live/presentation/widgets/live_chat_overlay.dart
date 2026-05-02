import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/live/domain/live_chat_message.dart';

class LiveChatOverlay extends StatefulWidget {
  final List<LiveChatMessage> messages;

  const LiveChatOverlay({super.key, required this.messages});

  @override
  State<LiveChatOverlay> createState() => _LiveChatOverlayState();
}

class _LiveChatOverlayState extends State<LiveChatOverlay> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant LiveChatOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.messages.length != oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;

        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final visibleMessages = widget.messages.length > 10
        ? widget.messages.sublist(widget.messages.length - 10)
        : widget.messages;

    return Positioned(
      left: 12,
      right: 80,
      bottom: 120,
      child: SizedBox(
        height: 260,
        child: ListView.builder(
          controller: _scrollController,
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
                    TextSpan(
                      text: '${msg.username}: ',
                      style: context.p.copyWith(
                        color: colors.amber,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: msg.message,
                      style: context.p.copyWith(
                        color: colors.white,
                        shadows: const [
                          Shadow(blurRadius: 4, color: Colors.black54),
                        ],
                      ),
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
