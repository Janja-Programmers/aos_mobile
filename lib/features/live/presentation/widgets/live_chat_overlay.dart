import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/live/domain/live_chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
        if (_scrollController.position.pixels > 80) return;
        _scrollController.jumpTo(0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final visibleMessages = widget.messages.take(10).toList(growable: false);

    return Positioned(
      left: 12,
      right: 78,
      bottom: 122,
      child: SizedBox(
        height: 260,
        child: ListView.builder(
          scrollCacheExtent: const ScrollCacheExtent.pixels(120),
          controller: _scrollController,
          reverse: true,
          padding: EdgeInsets.zero,
          itemCount: visibleMessages.length,
          itemBuilder: (_, index) {
            final msg = visibleMessages[index];

            return RepaintBoundary(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .38),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .08),
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${msg.username}: ',
                          style: context.p.copyWith(
                            color: colors.amber,
                            fontWeight: FontWeight.w700,
                            shadows: const [
                              Shadow(blurRadius: 4, color: Colors.black54),
                            ],
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
