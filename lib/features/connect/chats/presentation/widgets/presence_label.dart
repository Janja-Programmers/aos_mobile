import 'package:flutter/material.dart';

class PresenceLabel extends StatelessWidget {
  final bool isOnline;
  final DateTime? lastSeen;

  const PresenceLabel({super.key, required this.isOnline, this.lastSeen});

  @override
  Widget build(BuildContext context) {
    if (isOnline) {
      return const Text(
        "Online",
        style: TextStyle(color: Colors.green, fontSize: 12),
      );
    }

    if (lastSeen != null) {
      return Text(
        "Last seen ${_format(lastSeen!)}",
        style: const TextStyle(fontSize: 12),
      );
    }

    return const SizedBox.shrink();
  }

  String _format(DateTime dt) {
    return "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
