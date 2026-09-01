import 'package:africaonlinestores/core/media/application/media_services_provider.dart';
import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _StoreImageSource { gallery, camera }

Future<AcquiredMedia?> showStoreImageSourceSheet(
  BuildContext context, {
  required WidgetRef ref,
}) async {
  final source = await showDialog<_StoreImageSource>(
    context: context,
    builder: (dialogContext) {
      final colors = dialogContext.appColors;
      return Dialog(
        backgroundColor: colors.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Store banner',
                          style: dialogContext.h5.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: MaterialLocalizations.of(
                          dialogContext,
                        ).closeButtonTooltip,
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: Icon(
                          Icons.close_rounded,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.photo_library_outlined,
                      color: colors.primary,
                    ),
                    title: const Text('Upload banner'),
                    onTap: () =>
                        Navigator.pop(dialogContext, _StoreImageSource.gallery),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.photo_camera_outlined,
                      color: colors.primary,
                    ),
                    title: const Text('Take photo'),
                    onTap: () =>
                        Navigator.pop(dialogContext, _StoreImageSource.camera),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
  if (source == null || !context.mounted) return null;

  final acquisition = ref.read(mediaAcquisitionServiceProvider);
  return switch (source) {
    _StoreImageSource.gallery => acquisition.pickImage(
      useCase: MediaUseCase.sellerBanner,
    ),
    _StoreImageSource.camera => acquisition.captureImage(
      context,
      useCase: MediaUseCase.sellerBanner,
    ),
  };
}
