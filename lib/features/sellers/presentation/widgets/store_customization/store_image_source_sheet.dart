import 'package:africaonlinestores/core/media/application/media_services_provider.dart';
import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _StoreImageSource { gallery, camera }

Future<AcquiredMedia?> showStoreImageSourceSheet(
  BuildContext context, {
  required WidgetRef ref,
}) async {
  final source = await showModalBottomSheet<_StoreImageSource>(
    context: context,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Gallery'),
              onTap: () =>
                  Navigator.pop(sheetContext, _StoreImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () =>
                  Navigator.pop(sheetContext, _StoreImageSource.camera),
            ),
          ],
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
