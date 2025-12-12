import 'package:flutter/material.dart';

class ProductsEmptyWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ProductsEmptyWidget({
    super.key,
    this.message = 'Searched products not found.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ----- MESSAGE -----
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // ----- RETRY BUTTON -----
            ElevatedButton.icon(
              onPressed: onRetry,
              label: const Text('Go back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
