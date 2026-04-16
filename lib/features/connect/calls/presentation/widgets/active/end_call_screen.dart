import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class EndCallSection extends StatelessWidget {
  final Future<void> Function() onEnd;

  const EndCallSection({super.key, required this.onEnd});

  @override
  Widget build(BuildContext context) {
    return Center(child: EndCallButton(onTap: onEnd, size: 64));
  }
}

class EndCallButton extends StatelessWidget {
  final double size;
  final Future<void> Function() onTap;

  const EndCallButton({super.key, required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: colors.primary, blurRadius: 12, spreadRadius: 4),
        ],
      ),
      child: Material(
        color: colors.primary,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: Icon(
              Icons.call_end_rounded,
              color: colors.white,
              size: size * 0.34,
            ),
          ),
        ),
      ),
    );
  }
}
