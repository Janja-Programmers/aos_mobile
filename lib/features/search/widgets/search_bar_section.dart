import 'package:flutter/material.dart';
import 'package:africaonlinestores/core/core.dart';

class SearchBarSection extends StatelessWidget {
  const SearchBarSection({
    super.key,
    required this.controller,
    this.autofocus = false,
    this.onSubmitted,
    this.onMicTap,
    this.onCameraTap,
  });

  final TextEditingController controller;
  final bool autofocus;

  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onMicTap;
  final VoidCallback? onCameraTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),

            /// SEARCH ICON
            Icon(Icons.search, color: colors.textMuted),

            const SizedBox(width: 10),

            /// TEXT FIELD
            Expanded(
              child: TextField(
                controller: controller,
                autofocus: autofocus,
                textInputAction: TextInputAction.search,
                onSubmitted: onSubmitted,
                decoration: InputDecoration(
                  hintText: "Search here...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: colors.textMuted),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
            ),

            /// CLEAR BUTTON
            if (controller.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.close, color: colors.textMuted),
                onPressed: () {
                  controller.clear();
                },
              ),

            /// MIC BUTTON
            IconButton(
              icon: Icon(Icons.mic, color: colors.textPrimary),
              onPressed: onMicTap,
            ),

            /// CAMERA BUTTON
            IconButton(
              icon: Icon(Icons.camera_alt_outlined, color: colors.textPrimary),
              onPressed: onCameraTap,
            ),

            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}
