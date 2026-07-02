import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommentInput extends ConsumerStatefulWidget {
  final String shortId;
  final VoidCallback? onCommentAdded;

  const CommentInput({super.key, required this.shortId, this.onCommentAdded});

  @override
  ConsumerState<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends ConsumerState<CommentInput> {
  final TextEditingController _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _submitting) return;

    FocusScope.of(context).unfocus();

    setState(() => _submitting = true);

    try {
      await ref
          .read(commentsControllerProvider.notifier)
          .addComment(shortId: widget.shortId, comment: text);

      widget.onCommentAdded?.call();

      _controller.clear();

      if (!mounted) return;

      ShowSnack(context, 'Comment added').success();
    } catch (e) {
      if (!mounted) return;

      appLogger.e('Failed to add comment: $e');

      ShowSnack(context, 'Failed to add comment: $e').error();
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SafeArea(
      top: false,
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
                  color: colors.surface.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.border.withValues(alpha: 0.4),
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  style: context.p,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: _submitting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.white,
                        ),
                      )
                    : Icon(Icons.send, color: colors.white),
                onPressed: _submitting ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
