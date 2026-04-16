import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';

class LiveChatOverlay extends StatelessWidget {
  final List<String> messages;

  const LiveChatOverlay({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      right: 80,
      bottom: 120,
      child: ListView.builder(
        reverse: true,
        shrinkWrap: true,
        itemCount: messages.length,
        itemBuilder: (_, i) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              messages[i],
              style: context.p.copyWith(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
