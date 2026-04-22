import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/comments/comments_input.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/comments/comments_list.dart';

import 'package:africaonlinestores/features/shorts/create_short/domain/entities/short.dart';

class CommentsSheet extends ConsumerWidget {
  final Short short;

  const CommentsSheet({super.key, required this.short});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final String shortId = short.id.value;

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
              color: colors.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 12),

          // 🧾 TITLE
          Text(
            "${short.metrics.commentCount} Comments",
            style: context.p.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          const Divider(height: 1),

          // 📜 LIST
          Expanded(child: CommentsList(shortId: shortId)),

          const Divider(height: 1),

          // ✍️ INPUT
          CommentInput(shortId: shortId),
        ],
      ),
    );
  }
}
