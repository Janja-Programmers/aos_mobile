import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class ReplyInput extends StatefulWidget {
  final TextEditingController controller;
  final Future<void> Function() onSend;

  const ReplyInput({super.key, required this.controller, required this.onSend});

  @override
  State<ReplyInput> createState() => _ReplyInputState();
}

class _ReplyInputState extends State<ReplyInput> {
  bool _sending = false;

  Future<void> _submit() async {
    if (_sending) return;

    final text = widget.controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);

    try {
      await widget.onSend();
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: colors.surface.withOpacity(0.7),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.border.withOpacity(0.5)),
            ),
            child: TextField(
              controller: widget.controller,
              minLines: 1,
              maxLines: 3,
              style: context.p,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                hintText: 'Reply...',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        SizedBox(
          width: 38,
          height: 38,
          child: IconButton.filled(
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(
              backgroundColor: colors.primary,
              disabledBackgroundColor: colors.border,
            ),
            onPressed: _sending ? null : _submit,
            icon: _sending
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.white,
                    ),
                  )
                : Icon(Icons.send_rounded, size: 18, color: colors.white),
          ),
        ),
      ],
    );
  }
}
