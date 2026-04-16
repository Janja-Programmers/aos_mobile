import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class TopBar extends StatelessWidget {
  final bool isConnected;

  const TopBar({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _TopSquareButton(
          icon: Icons.keyboard_arrow_down_rounded,
          iconSize: 32,
          onTap: () {},
        ),
        _StatusBadge(isConnected: isConnected),
        _TopSquareButton(
          icon: Icons.more_vert_rounded,
          iconSize: 28,
          onTap: () {},
        ),
      ],
    );
  }
}

class _TopSquareButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final VoidCallback onTap;

  const _TopSquareButton({
    required this.icon,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
          ),
          child: Icon(icon, size: iconSize),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isConnected;

  const _StatusBadge({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.signal_cellular_alt_rounded,
            color: isConnected ? colors.success : colors.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            isConnected ? 'HD' : 'Joining',
            style: context.pStrong.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
