import 'package:flutter/material.dart';

class CaptionInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onChanged;
  final void Function(List<String>) onHashtagsChanged;

  const CaptionInput({
    super.key,
    required this.controller,
    required this.onHashtagsChanged,
    this.onChanged,
  });

  List<String> _extractTags(String value) {
    return value
        .split(RegExp(r'\s+'))
        .where((e) => e.trim().startsWith('#') && e.trim().length > 1)
        .map((e) => e.trim())
        .toSet()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 110),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        controller: controller,
        maxLength: 220,
        maxLines: 5,
        minLines: 3,
        style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.45),
        decoration: const InputDecoration(
          hintText: 'Write a caption and add #hashtags',
          hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
          border: InputBorder.none,
          counterText: '',
        ),
        onChanged: (value) {
          onHashtagsChanged(_extractTags(value));
          onChanged?.call();
        },
      ),
    );
  }
}
