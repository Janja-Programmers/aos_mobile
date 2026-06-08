import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class SocialConnectionsStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  const SocialConnectionsStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  factory SocialConnectionsStateView.empty({
    required String title,
    required String message,
  }) {
    return SocialConnectionsStateView(
      icon: Icons.people_outline_rounded,
      title: title,
      message: message,
    );
  }

  factory SocialConnectionsStateView.error({
    required String message,
    Future<void> Function()? onRetry,
  }) {
    return SocialConnectionsStateView(
      icon: Icons.wifi_off_rounded,
      title: 'Could not load people',
      message: message,
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: colors.elevated,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colors.textMuted, size: 34),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: context.h5.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                message,
                style: context.pMuted.copyWith(height: 1.35),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 16),
                ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
