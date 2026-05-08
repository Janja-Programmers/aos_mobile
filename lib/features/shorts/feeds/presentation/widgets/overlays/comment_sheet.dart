import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/comments/comments_input.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/comments/comments_list.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';

class CommentsSheet extends ConsumerStatefulWidget {
  final Short short;
  final VoidCallback onCommentAdded;

  const CommentsSheet({
    super.key,
    required this.short,
    required this.onCommentAdded,
  });

  @override
  ConsumerState<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<CommentsSheet> {
  late int _commentCount;

  @override
  void initState() {
    super.initState();
    _commentCount = widget.short.metrics.commentCount;
  }

  void _handleCommentAdded() {
    setState(() {
      _commentCount++;
    });

    widget.onCommentAdded();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final shortId = widget.short.id.value;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),

            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              '$_commentCount ${_commentCount == 1 ? "Comment" : "Comments"}',
              style: context.pStrong,
            ),

            const SizedBox(height: 12),

            const Divider(height: 1),

            Expanded(child: CommentsList(shortId: shortId)),

            const Divider(height: 1),

            CommentInput(shortId: shortId, onCommentAdded: _handleCommentAdded),
          ],
        ),
      ),
    );
  }
}
