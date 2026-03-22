import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

/// Ready-to-use bottom actions for Ad Details:
/// Home (icon-only), Call (filled), Message (outlined).
class AdDetailActionBar extends StatelessWidget {
  const AdDetailActionBar({super.key, this.onCall, this.onMessage});

  final VoidCallback? onCall;
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
              onTap: onCall ?? () => context.pushNamed(AppRoutes.nHome),
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

  static const _radius = BorderRadius.all(Radius.circular(999));

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    final isIconOnly = label == null || label!.trim().isEmpty;

    final iconColor = filled ? appColors.white : appColors.primary;
    final textColor = filled ? appColors.white : appColors.primary;

    final filledStyle = FilledButton.styleFrom(
      shape: const RoundedRectangleBorder(borderRadius: _radius),
    );

    final outlinedStyle = OutlinedButton.styleFrom(
      shape: const RoundedRectangleBorder(borderRadius: _radius),
    );

    if (isIconOnly) {
      final buttonStyle =
          (filled ? FilledButton.styleFrom() : OutlinedButton.styleFrom())
              .copyWith(
                padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
                shape: const WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                alignment: Alignment.center,
              );

      return SizedBox(
        height: 48,
        width: 48,
        child: filled
            ? FilledButton(
                onPressed: onTap,
                style: buttonStyle,
                child: Icon(icon, size: 20, color: iconColor),
              )
            : OutlinedButton(
                onPressed: onTap,
                style: buttonStyle,
                child: Icon(icon, size: 20, color: iconColor),
              ),
      );
    }

    return SizedBox(
      height: 48,
      child: filled
          ? FilledButton.icon(
              onPressed: onTap,
              style: filledStyle,
              icon: Icon(icon, size: 18, color: iconColor),
              label: Text(
                label!,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              style: outlinedStyle,
              icon: Icon(icon, size: 18, color: iconColor),
              label: Text(
                label!,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
              ),
            ),
    );
  }
}
