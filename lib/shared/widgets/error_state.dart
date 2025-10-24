import 'package:flutter/material.dart';

class ErrorState extends StatelessWidget {
  /// Name of the resource or entity (e.g. "orders", "stock items")
  final String resource;

  /// Optional custom message override
  final String? message;

  /// Optional retry button label
  final String? actionLabel;

  /// Optional retry callback
  final VoidCallback? onAction;

  const ErrorState({
    super.key,
    required this.resource,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Build a default friendly message if none is provided
    final displayMessage =
        message ??
        'Could not load $resource. Please check your connection and try again.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 72,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              "You're offline",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              displayMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                ),
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
