import 'package:flutter/material.dart';

class PostShortPicker extends StatelessWidget {
  final VoidCallback onPick;

  const PostShortPicker({super.key, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F0F10), Color(0xFF17181C), Color(0xFF0B0B0C)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.video_library_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Create a Short',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: onPick,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Select Video'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
