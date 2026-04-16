import 'package:flutter/material.dart';

class SavedEmptyState extends StatelessWidget {
  const SavedEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Icon container (better than raw icon)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_border,
                size: 36,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            /// Title
            const Text(
              'No saved posts yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            /// Subtitle
            const Text(
              'Tap the bookmark icon to save posts',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
