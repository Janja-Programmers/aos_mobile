import 'package:flutter/material.dart';

class ReplyInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const ReplyInput({super.key, required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(radius: 14),

        const SizedBox(width: 8),

        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Write a reply...",
              border: InputBorder.none,
            ),
          ),
        ),

        IconButton(icon: const Icon(Icons.send, size: 18), onPressed: onSend),
      ],
    );
  }
}
