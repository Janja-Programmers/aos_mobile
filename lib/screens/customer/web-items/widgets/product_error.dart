import 'package:flutter/material.dart';

class ProductsErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ProductsErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, color: Colors.red, size: 48),
        SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        SizedBox(height: 20),
        ElevatedButton(onPressed: onRetry, child: Text("Retry")),
      ],
    );
  }
}
