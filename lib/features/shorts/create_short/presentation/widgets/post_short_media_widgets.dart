import 'dart:io';

import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:flutter/material.dart';

class PostShortMediaWidgets {
  PostShortMediaWidgets._();

  /// Bottom gradient
  static Widget bottomGradient(AppColorTokens colors) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, colors.black.withValues(alpha: .6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  /// Count badge
  static Widget countBadge(AppColorTokens colors, int count, TextStyle style) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.black.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('$count', style: style),
    );
  }

  /// Thumbnail preview
  static Widget previewItem({
    required File file,
    required bool isVideo,
    required VoidCallback onRemove,
    required AppColorTokens colors,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(file, width: 70, height: 70, fit: BoxFit.cover),
        ),

        if (isVideo)
          Positioned.fill(
            child: Container(
              color: colors.black.withValues(alpha: .5),
              alignment: Alignment.center,
              child: Icon(Icons.videocam, color: colors.white),
            ),
          ),

        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.black,
                shape: BoxShape.circle,
                border: Border.all(color: colors.white),
              ),
              child: Icon(Icons.close, size: 16, color: colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
