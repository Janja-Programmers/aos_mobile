import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/shorts/application/providers/shorts_providers.dart';

class CommentInput extends ConsumerStatefulWidget {
  final String shortId;

  const CommentInput({super.key, required this.shortId});

  @override
  ConsumerState<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends ConsumerState<CommentInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final state = ref.watch(commentsControllerProvider);
    final loading = state.isLoading;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        child: Row(
          children: [
            CircleAvatar(radius: 18, backgroundColor: colors.border),

            const SizedBox(width: 10),

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: colors.surface.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _controller,
                  style: context.p,
                  decoration: const InputDecoration(
                    hintText: "Add a comment...",
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
                icon: loading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.white,
                        ),
                      )
                    : Icon(Icons.send, color: colors.white),
                onPressed: loading
                    ? null
                    : () async {
                        final text = _controller.text.trim();
                        if (text.isEmpty) return;

                        await ref
                            .read(commentsControllerProvider.notifier)
                            .addComment(shortId: widget.shortId, comment: text);

                        _controller.clear();
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
