import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class LiveRightActions extends StatelessWidget {
  final VoidCallback onLike;
  final VoidCallback onFlip;
  final VoidCallback onMute;
  final VoidCallback onCohost;
  final bool isHost;
  final bool isMuted;

  const LiveRightActions({
    super.key,
    required this.onLike,
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
      bottom: 128,
      child: Column(
        children: [
          _btn(context, Icons.favorite_border, onLike),
          const SizedBox(height: 12),
          _btn(context, Icons.group_add_outlined, onCohost),
          const SizedBox(height: 12),
          _btn(
            context,
            isMuted ? Icons.mic_off_outlined : Icons.mic_none_outlined,
            onMute,
          ),
          if (isHost) ...[
            const SizedBox(height: 12),
            _btn(context, Icons.cameraswitch, onFlip),
          ],
        ],
      ),
    );
  }

  Widget _btn(BuildContext context, IconData icon, VoidCallback onTap) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 22,
        backgroundColor: colors.black.withOpacity(.6),
        child: Icon(icon, color: colors.white),
      ),
    );
  }
}
