import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class CaptionInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<List<String>>? onHashtagsChanged;

  const CaptionInput({
    super.key,
    required this.controller,
    this.onChanged,
    this.onHashtagsChanged,
  });

  List<String> _extractHashtags(String value) {
    return value
        .split(RegExp(r'\s+'))
        .where((e) => e.startsWith('#') && e.length > 1)
        .map((e) => e.trim())
        .toSet()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final inputDecorationTheme = Theme.of(context).inputDecorationTheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 150),
      child: TextField(
        controller: controller,
        maxLength: 512,
        maxLines: 8,
        minLines: 6,
        style: context.pMuted.copyWith(
          color: colors.textPrimary,
          fontSize: 15,
          height: 1.4,
        ),
        decoration: InputDecoration(
          hintText:
              "What's on your mind? Describe your post, share a story, or tell people about your product...",
          filled: true,
          fillColor: colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colors.border),
          ),
        ).applyDefaults(inputDecorationTheme),

        onChanged: (value) {
          onChanged?.call(value);
          onHashtagsChanged?.call(_extractHashtags(value));
        },
      ),
    );
  }
}
