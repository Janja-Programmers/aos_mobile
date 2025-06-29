import 'package:flutter/material.dart';

enum TopSnackType { info, success, error }

void topSnackBar(
  BuildContext context,
  String message, {
  TopSnackType type = TopSnackType.success,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);
  final color = switch (type) {
    TopSnackType.success => Colors.green.shade600,
    TopSnackType.error => Colors.red.shade600,
    TopSnackType.info => Colors.blue.shade600,
  };

  final overlayEntry = OverlayEntry(
    builder: (_) => Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: AnimatedSlide(
          offset: Offset.zero,
          duration: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(switch (type) {
                  TopSnackType.success => Icons.check_circle,
                  TopSnackType.error => Icons.error,
                  TopSnackType.info => Icons.info,
                }, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(duration, () {
    overlayEntry.remove();
  });
}
