import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class LiveRightActions extends StatelessWidget {
  final VoidCallback onLike;
  final VoidCallback onFlip;

  const LiveRightActions({
    super.key,
    required this.onLike,
    required this.onFlip,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 12,
      bottom: 120,
      child: Column(
        children: [
          _btn(context, Icons.favorite_border, onLike),
          const SizedBox(height: 12),

          _btn(context, Icons.cameraswitch, onFlip),
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
