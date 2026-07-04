import 'package:flutter/material.dart';

class ConnectIcon extends StatelessWidget {
  final double size;
  final Color color;
  final Color? phoneColor;

  const ConnectIcon({
    super.key,
    this.size = 28,
    required this.color,
    this.phoneColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePhoneColor = phoneColor ?? color;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.mode_comment_outlined, size: size, color: color),
          Positioned(
            bottom: size * 0.30,
            child: Icon(
              Icons.phone_outlined,
              size: size * 0.46,
              color: effectivePhoneColor,
            ),
          ),
        ],
      ),
    );
  }
}
