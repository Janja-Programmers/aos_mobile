import 'dart:async';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/live/domain/live_reaction.dart';
import 'package:flutter/material.dart';

class FloatingHearts extends StatefulWidget {
  const FloatingHearts({
    super.key,
    required this.trigger,
    this.reactionType = LiveReactionType.like,
  });

  final int trigger;
  final LiveReactionType reactionType;

  @override
  State<FloatingHearts> createState() => _FloatingHeartsState();
}

class _FloatingHeartsState extends State<FloatingHearts> {
  final List<_ReactionItem> reactions = [];

  @override
  void didUpdateWidget(covariant FloatingHearts oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.trigger != oldWidget.trigger) {
      _addReaction(widget.reactionType);
    }
  }

  void _addReaction(LiveReactionType reactionType) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    setState(() {
      reactions.add(_ReactionItem(id: id, reactionType: reactionType));
    });

    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 1600), () {
        if (!mounted) return;

        setState(() {
          reactions.removeWhere((item) => item.id == id);
        });
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      end: 28,
      bottom: 190,
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          children: reactions
              .map((reaction) {
                return TweenAnimationBuilder<double>(
                  key: ValueKey(reaction.id),
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1600),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, child) {
                    return Transform.translate(
                      offset: Offset(reaction.xOffset, -value * 220),
                      child: Opacity(
                        opacity: 1 - value,
                        child: Transform.scale(
                          scale: 0.72 + value,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: .24),
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 16,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                _iconFor(reaction.reactionType),
                                color: _colorFor(
                                  context,
                                  reaction.reactionType,
                                ),
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              })
              .toList(growable: false),
        ),
      ),
    );
  }

  IconData _iconFor(LiveReactionType reactionType) {
    switch (reactionType) {
      case LiveReactionType.fire:
        return Icons.local_fire_department_rounded;
      case LiveReactionType.clap:
        return Icons.front_hand_rounded;
      case LiveReactionType.love:
      case LiveReactionType.like:
        return Icons.favorite_rounded;
      case LiveReactionType.wow:
        return Icons.emoji_emotions_rounded;
    }
  }

  Color _colorFor(BuildContext context, LiveReactionType reactionType) {
    switch (reactionType) {
      case LiveReactionType.fire:
      case LiveReactionType.wow:
        return context.appColors.amber;
      case LiveReactionType.like:
      case LiveReactionType.clap:
      case LiveReactionType.love:
        return context.appColors.primary;
    }
  }
}

class _ReactionItem {
  _ReactionItem({required this.id, required this.reactionType})
    : xOffset = ((DateTime.now().millisecond % 54) - 27).toDouble();

  final String id;
  final LiveReactionType reactionType;
  final double xOffset;
}
