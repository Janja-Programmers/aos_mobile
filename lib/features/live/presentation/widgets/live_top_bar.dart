import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class LiveTopBar extends StatelessWidget {
  final int viewerCount;
  final Duration duration;
  final VoidCallback onEnd;

  const LiveTopBar({
    super.key,
    required this.viewerCount,
    required this.duration,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    String format(Duration d) {
      return "${d.inMinutes.toString().padLeft(2, '0')}:"
          "${(d.inSeconds % 60).toString().padLeft(2, '0')}";
    }

    return Positioned(
      top: 40,
      left: 12,
      right: 12,
      child: Row(
        children: [
          /// LEFT GROUP
          Row(
            children: [
              /// LIVE BADGE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      "LIVE",
                      style: context.p.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              /// TIMER
              _blackBox(context, format(duration)),

              const SizedBox(width: 6),

              /// VIEWERS
              _blackBox(context, "$viewerCount", icon: Icons.remove_red_eye),
            ],
          ),

          const Spacer(),

          /// END BUTTON
          GestureDetector(
            onTap: onEnd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "End",
                style: context.p.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blackBox(BuildContext context, String text, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          if (icon != null) Icon(icon, size: 14, color: Colors.white),
          if (icon != null) const SizedBox(width: 4),
          Text(text, style: context.p.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}
