import 'package:flutter/material.dart';

import '/core/errors/failures.dart';

class FailureDisplay extends StatelessWidget {
  final Failure failure;
  final VoidCallback onRetry;

  const FailureDisplay({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
          const SizedBox(height: 8),
          Text(
            failure.message, // <-- clean string only
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.red.shade400),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}
