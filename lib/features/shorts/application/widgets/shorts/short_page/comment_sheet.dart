import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/shorts/application/widgets/shorts/comments/comments_input.dart';
import 'package:africaonlinestores/features/shorts/application/widgets/shorts/comments/comments_list.dart';

class CommentsSheet extends ConsumerWidget {
  const CommentsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),

          // 🔘 HANDLE
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 12),

          // 🧾 TITLE
          Text(
            "328 Comments",
            style: context.p.copyWith(
              color: colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          const Divider(height: 1),

          // 📜 LIST
          const Expanded(child: CommentsList()),

          const Divider(height: 1),

          // ✍️ INPUT
          const CommentInput(),
        ],
      ),
    );
  }
}
