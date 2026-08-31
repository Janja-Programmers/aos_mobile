import 'dart:io';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/account/shared/utils/avator_image.dart';
import 'package:africaonlinestores/shared/images/app_image_decode.dart';
import 'package:flutter/material.dart';

class EditableAvatar extends StatelessWidget {
  const EditableAvatar({
    super.key,
    required this.baseUrl,
    required this.authFullName,
    required this.authUserImage,
    required this.apiUserImage,
    required this.localPhoto,
    required this.uploading,
    required this.onTapCamera,
  });

  final String baseUrl;
  final String authFullName;
  final String authUserImage;
  final String apiUserImage;
  final File? localPhoto;
  final bool uploading;
  final VoidCallback onTapCamera;

  static const BorderRadius _pill = BorderRadius.all(Radius.circular(99));

  ImageProvider<Object>? _imageProvider(BuildContext context) {
    if (localPhoto != null) {
      return AppImageDecode.fileProvider(
        context,
        localPhoto!,
        logicalWidth: 92,
        logicalHeight: 92,
      );
    }

    final ImageProvider<Object>? provider =
        resolveAvatarImage(apiUserImage, baseUrl) ??
        resolveAvatarImage(authUserImage, baseUrl);

    if (provider == null) return null;

    return AppImageDecode.resizeProvider(
      context,
      provider,
      logicalWidth: 92,
      logicalHeight: 92,
    );
  }

  String _initial() {
    final name = authFullName.trim();
    if (name.isEmpty) return 'U';
    return name.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    final ImageProvider<Object>? img = _imageProvider(context);
    final hasImage = img != null;

    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 46,
          backgroundColor: scheme.onPrimary,
          backgroundImage: img,
          onBackgroundImageError: hasImage ? (_, _) {} : null,
          child: hasImage
              ? null
              : Text(
                  _initial(),
                  style: context.h3.copyWith(color: colors.border),
                ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            onTap: uploading ? null : onTapCamera,
            borderRadius: _pill,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: _pill,
                border: Border.all(color: scheme.surface, width: 2),
              ),
              child: uploading
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          scheme.onPrimary,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.camera_alt_outlined,
                      color: context.appColors.border,
                      size: 18,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
