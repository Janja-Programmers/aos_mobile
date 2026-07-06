import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class LiveInputBar extends StatefulWidget {
  final TextEditingController controller;
  final Future<void> Function() onSend;
  final bool isSending;

  const LiveInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.isSending = false,
  });

  @override
  State<LiveInputBar> createState() => _LiveInputBarState();
}

class _LiveInputBarState extends State<LiveInputBar> {
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(covariant LiveInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_handleTextChanged);
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_handleTextChanged);
  }

  void _handleTextChanged() {
    final next = widget.controller.text.trim().isNotEmpty;
    if (next == _hasText) return;
    setState(() => _hasText = next);
  }

  void _submit() {
    if (!_hasText || widget.isSending) return;
    unawaited(widget.onSend());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final canSend = _hasText && !widget.isSending;

    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      left: 12,
      right: 12,
      bottom: keyboardInset,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: .46),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: .14)),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                color: Colors.black.withValues(alpha: .22),
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 14,
              end: 6,
              top: 6,
              bottom: 6,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    keyboardType: TextInputType.multiline,
                    style: context.p.copyWith(color: Colors.white),
                    cursorColor: colors.primary,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Comment live...',
                      hintStyle: AppTextStylesX(
                        context,
                      ).caption.copyWith(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkResponse(
                  onTap: canSend ? _submit : null,
                  radius: 24,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: canSend
                          ? colors.primary
                          : Colors.white.withValues(alpha: .16),
                      shape: BoxShape.circle,
                    ),
                    child: widget.isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChanged);
    _focusNode.dispose();
    super.dispose();
  }
}
