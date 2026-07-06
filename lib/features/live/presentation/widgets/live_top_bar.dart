import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class LiveTopBar extends StatelessWidget {
  final int viewerCount;
  final VoidCallback onEnd;
  final bool isHost;

  const LiveTopBar({
    super.key,
    required this.viewerCount,
    required this.onEnd,
    required this.isHost,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Positioned(
      top: 40,
      left: 12,
      right: 12,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: colors.white),
                const SizedBox(width: 4),
                Text('LIVE', style: context.p.copyWith(color: colors.white)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          _blackBox(context, '$viewerCount', icon: Icons.remove_red_eye),
          const Spacer(),
          GestureDetector(
            onTap: onEnd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isHost ? 'End' : 'Leave',
                style: context.p.copyWith(color: colors.primary),
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
        color: Colors.black.withValues(alpha: .62),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 14, color: Colors.white),
          if (icon != null) const SizedBox(width: 4),
          Text(text, style: context.p.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}
