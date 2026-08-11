import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/live/domain/live_reaction.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';

class LiveRightActions extends StatelessWidget {
  const LiveRightActions({
    super.key,
    required this.onLike,
    required this.onShare,
    required this.onFlip,
    required this.onMute,
    required this.onCohost,
    required this.isHost,
    required this.isMuted,
    this.onReaction,
    this.showReaction = true,
    this.showShare = true,
    this.showCohost = false,
  });

  final VoidCallback onLike;
  final VoidCallback onShare;
  final VoidCallback onFlip;
  final VoidCallback onMute;
  final VoidCallback onCohost;
  final ValueChanged<LiveReactionType>? onReaction;
  final bool isHost;
  final bool isMuted;
  final bool showReaction;
  final bool showShare;
  final bool showCohost;

  @override
  Widget build(BuildContext context) {
    final maxHeight = (MediaQuery.sizeOf(context).height - 320)
        .clamp(48.0, 520.0)
        .toDouble();
    return PositionedDirectional(
      end: 12,
      bottom: 132,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (showReaction)
                  _ReactionAction(onTap: onLike, onReaction: onReaction),
                if (showReaction && showShare) const SizedBox(height: 12),
                if (showShare)
                  _button(
                    context,
                    icon: Icons.share_rounded,
                    tooltip: context.l10n.liveShareAction,
                    onPressed: onShare,
                  ),
                if (showCohost) ...[
                  const SizedBox(height: 12),
                  _button(
                    context,
                    icon: Icons.group_add_outlined,
                    tooltip: 'Co-host',
                    onPressed: onCohost,
                  ),
                ],
                if (isHost) ...[
                  const SizedBox(height: 12),
                  _button(
                    context,
                    icon: isMuted
                        ? Icons.mic_off_outlined
                        : Icons.mic_none_outlined,
                    tooltip: isMuted
                        ? context.l10n.liveUnmuteAction
                        : context.l10n.liveMuteAction,
                    onPressed: onMute,
                  ),
                  const SizedBox(height: 12),
                  _button(
                    context,
                    icon: Icons.cameraswitch_rounded,
                    tooltip: context.l10n.liveFlipCameraAction,
                    onPressed: onFlip,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _button(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.black.withValues(alpha: .62),
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(
        dimension: 48,
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon, color: colors.white),
        ),
      ),
    );
  }
}

class _ReactionAction extends StatelessWidget {
  const _ReactionAction({required this.onTap, required this.onReaction});

  final VoidCallback onTap;
  final ValueChanged<LiveReactionType>? onReaction;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Tooltip(
      message: context.l10n.liveLikeAction,
      child: Semantics(
        button: true,
        label: context.l10n.liveLikeAction,
        hint: onReaction == null ? null : 'Long press for more reactions',
        child: Material(
          color: colors.black.withValues(alpha: .62),
          shape: const CircleBorder(),
          child: InkResponse(
            onTap: onTap,
            onLongPress: onReaction == null
                ? null
                : () => _showReactionPicker(context),
            radius: 28,
            child: SizedBox.square(
              dimension: 48,
              child: Icon(Icons.favorite_border_rounded, color: colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showReactionPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<LiveReactionType>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colors = context.appColors;
        return Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 6,
                  runSpacing: 8,
                  children: LiveReactionType.values
                      .map((reaction) {
                        return Semantics(
                          button: true,
                          label: reaction.label,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => Navigator.of(context).pop(reaction),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 56,
                                minHeight: 56,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    reaction.emoji,
                                    style: const TextStyle(fontSize: 30),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(reaction.label),
                                ],
                              ),
                            ),
                          ),
                        );
                      })
                      .toList(growable: false),
                ),
              ),
            ),
          ),
        );
      },
    );
    if (!context.mounted) return;
    if (selected != null) onReaction?.call(selected);
  }
}
