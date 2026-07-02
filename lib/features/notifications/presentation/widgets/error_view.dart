import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class NotofcationErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const NotofcationErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: context.pStrong),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRetry,
            child: Text('Retry', style: context.p),
          ),
        ],
      ),
    );
  }
}
