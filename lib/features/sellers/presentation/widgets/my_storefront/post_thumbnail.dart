import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/shared/images/app_image_decode.dart';
import 'package:flutter/material.dart';

class PostThumbnail extends StatelessWidget {
  const PostThumbnail({
    super.key,
    required this.duration,
    this.imageUrl,
    this.isLive = false,
  });

  final String duration;
  final String? imageUrl;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final url = imageUrl?.trim();

    return Stack(
      children: [
        Container(
          width: 92,
          height: 72,
          decoration: BoxDecoration(
            color: colors.border,
            borderRadius: BorderRadius.circular(10),
            image: url != null && url.isNotEmpty
                ? DecorationImage(
                    image: AppImageDecode.networkProvider(
                      context,
                      url,
                      logicalWidth: 92,
                      logicalHeight: 72,
                    ),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: url == null || url.isEmpty
              ? Icon(Icons.image_outlined, color: colors.border)
              : null,
        ),
        if (isLive)
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'LIVE',
                style: TextStyle(
                  color: colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        Positioned(
          right: 5,
          bottom: 5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            decoration: BoxDecoration(
              color: colors.black.withValues(alpha: .65),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              duration,
              style: TextStyle(
                color: colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
