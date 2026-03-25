import 'package:flutter/material.dart';

class ChatInputBar extends StatefulWidget {
  final Function(String text) onSend;
  final Function(bool) onTyping;

  const ChatInputBar({super.key, required this.onSend, required this.onTyping});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onChanged: (text) {
              widget.onTyping(text.isNotEmpty);
            },
            decoration: const InputDecoration(
              hintText: "Type a message...",
              border: InputBorder.none,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isEmpty) return;

            widget.onSend(text);
            _controller.clear();
            widget.onTyping(false);
          },
        ),
      ],
    );
  }
}
