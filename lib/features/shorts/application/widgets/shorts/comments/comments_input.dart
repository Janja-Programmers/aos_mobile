import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class CommentInput extends StatelessWidget {
  const CommentInput({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: colors.surface.withOpacity(0.5),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colors.surface.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                style: context.p.copyWith(color: colors.white),
                decoration: InputDecoration(
                  hintText: "Add a comment...",
                  hintStyle: context.p.copyWith(
                    color: colors.white.withOpacity(0.6),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          Container(
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
