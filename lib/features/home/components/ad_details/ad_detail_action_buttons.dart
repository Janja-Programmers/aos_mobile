import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/utils/app_snack.dart';

/// Ready-to-use bottom actions for Ad Details:
/// Home (icon-only), Call (filled), Message (outlined).
class AdDetailActionBar extends StatelessWidget {
  const AdDetailActionBar({super.key, this.onCall, this.onMessage});

  /// Optional override for Call action.
  /// If null, a default "Wire call action later" snack is shown.
  final VoidCallback? onCall;

  /// Optional override for Message action.
  /// If null, a default "Wire chat action later" snack is shown.
  final VoidCallback? onMessage;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            _AdDetailActionButton(
              icon: Icons.home_outlined,
              filled: false,
              label: null,
              onTap: () => context.push(AppRoutes.home),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: _AdDetailActionButton(
                icon: Icons.call,
                filled: true,
                label: 'Call',
                onTap:
                    onCall ??
                    () => ShowSnack(context, 'Wire call action later').info(),
              ),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: _AdDetailActionButton(
                icon: Icons.chat_bubble_outline,
                filled: false,
                label: 'Message',
                onTap:
                    onMessage ??
                    () => ShowSnack(context, 'Wire chat action later').info(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdDetailActionButton extends StatelessWidget {
  const _AdDetailActionButton({
    required this.icon,
    required this.filled,
    required this.onTap,
    this.label,
  });

  final IconData icon;
  final bool filled;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final appColors = context.appColors;

    final isIconOnly = label == null || label!.trim().isEmpty;

    // Your color rules:
    // - Outlined: primary
    // - Filled: appColors.border
    final iconColor = filled ? appColors.border : scheme.primary;
    final textColor = filled ? appColors.border : scheme.primary;

    if (isIconOnly) {
      return SizedBox(
        height: 48,
        width: 48,
        child: filled
            ? FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(padding: EdgeInsets.zero),
                child: Icon(icon, size: 20, color: iconColor),
              )
            : OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                child: Icon(icon, size: 20, color: iconColor),
              ),
      );
    }

    return SizedBox(
      height: 48,
      child: filled
          ? FilledButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 18, color: iconColor),
              label: Text(
                label!,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 18, color: iconColor),
              label: Text(
                label!,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
              ),
            ),
    );
  }
}
