import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';

class LiveRightActions extends StatelessWidget {
  final VoidCallback onLike;
  final VoidCallback onShare;
  final VoidCallback onFlip;
  final VoidCallback onMute;
  final VoidCallback onCohost;
  final bool isHost;
  final bool isMuted;

  const LiveRightActions({
    super.key,
    required this.onLike,
    required this.onShare,
    required this.onFlip,
    required this.onMute,
    required this.onCohost,
    required this.isHost,
    required this.isMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 12,
      bottom: 132,
      child: Column(
        children: [
          _button(
            context,
            icon: Icons.favorite_border_rounded,
            tooltip: context.l10n.liveLikeAction,
            onPressed: onLike,
          ),
          const SizedBox(height: 12),
          _button(
            context,
            icon: Icons.share_rounded,
            tooltip: context.l10n.liveShareAction,
            onPressed: onShare,
          ),
          // Co-host remains controlled by the existing co-host surface.
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
