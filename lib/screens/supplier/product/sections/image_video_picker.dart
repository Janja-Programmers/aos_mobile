import 'package:flutter/material.dart';

import '/features/product/domain/product.dart';

import '../controllers/add_item_controller.dart';

class ImageVideoPickerSection extends StatelessWidget {
  final AddItemController controller;
  final Product? product;

  const ImageVideoPickerSection({
    super.key,
    required this.controller,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        controller.uploadedImageUrl != null
            ? 'https://africaonlinestores.com${controller.uploadedImageUrl}'
            : (product?.image != null
                ? 'https://africaonlinestores.com${product!.image}'
                : null);

    final videoUrl =
        controller.uploadedVideoUrl != null
            ? 'https://africaonlinestores.com${controller.uploadedVideoUrl}'
            : (product?.demoVideo != null
                ? 'https://africaonlinestores.com${product!.demoVideo}'
                : null);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          children: [
            // IMAGE SECTION
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Image', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  controller.selectedImage != null
                      ? Image.file(
                        controller.selectedImage!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      )
                      : imageUrl != null
                      ? Image.network(
                        imageUrl,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(
                            height: 100,
                            width: 100,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                      )
                      : const Text('No image selected'),
                  const SizedBox(height: 8),
                  controller.isPickingImage
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                        onPressed:
                            controller.isPickingImage ||
                                    controller.isPickingVideo
                                ? null
                                : () =>
                                    controller.pickFile(context, isImage: true),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.attach_file),
                            SizedBox(width: 8),
                            Text('Attach'),
                          ],
                        ),
                      ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // VIDEO SECTION
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Demo Video',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  controller.selectedVideo != null
                      ? Text(
                        'Selected: ${controller.selectedVideo!.path.split('/').last}',
                      )
                      : videoUrl != null
                      ? Text('Video: $videoUrl')
                      : const Text('No video selected'),
                  const SizedBox(height: 8),
                  controller.isPickingVideo
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                        onPressed:
                            controller.isPickingImage ||
                                    controller.isPickingVideo
                                ? null
                                : () => controller.pickFile(
                                  context,
                                  isImage: false,
                                ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.video_file),
                            SizedBox(width: 8),
                            Text('Attach'),
                          ],
                        ),
                      ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
