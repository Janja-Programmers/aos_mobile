import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_message.dart';
import 'package:flutter/material.dart';

Future<String?> showChatEditMessageDialog(
  BuildContext context,
  ChatMessage message,
) {
  return showDialog<String>(
    context: context,
    builder: (_) => _ChatEditMessageDialog(message: message),
  );
}

class _ChatEditMessageDialog extends StatefulWidget {
  final ChatMessage message;

  const _ChatEditMessageDialog({required this.message});

  @override
  State<_ChatEditMessageDialog> createState() => _ChatEditMessageDialogState();
}

class _ChatEditMessageDialogState extends State<_ChatEditMessageDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.message.content ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  void _save() {
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AlertDialog(
      backgroundColor: colors.elevated,
      surfaceTintColor: Colors.transparent,
      title: Text('Edit message', style: TextStyle(color: colors.textPrimary)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        minLines: 1,
        maxLines: 5,
        style: TextStyle(color: colors.textPrimary),
        decoration: const InputDecoration(hintText: 'Message'),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: Text('Cancel', style: TextStyle(color: colors.textMuted)),
        ),
        TextButton(
          onPressed: _save,
          child: Text('Save', style: TextStyle(color: colors.primary)),
        ),
      ],
    );
  }
}
