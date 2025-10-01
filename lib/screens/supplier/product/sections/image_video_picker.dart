import 'package:flutter/material.dart';

import '/core/constants/colors.dart';
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
    final _ =
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

                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade200,
                    ),
                    child: Center(
                      child:
                          controller.selectedImage != null
                              ? Image.file(
                                controller.selectedImage!,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              )
                              : const Icon(
                                Icons.broken_image,
                                size: 40,
                                color: Colors.grey,
                              ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Attach button
                  controller.isPickingImage
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                        onPressed:
                            controller.isPickingImage ||
                                    controller.isPickingVideo
                                ? null
                                : () =>
                                    controller.pickFile(context, isImage: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
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

                  // Preview / filename
                  controller.selectedVideo != null
                      ? Stack(
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            color: Colors.black12,
                            child: Center(
                              child: Icon(
                                Icons.videocam,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap:
                                    () => controller.pickFile(
                                      context,
                                      isImage: false,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      )
                      : videoUrl != null
                      ? Stack(
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            color: Colors.black12,
                            child: Center(
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap:
                                    () => controller.pickFile(
                                      context,
                                      isImage: false,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      )
                      : const Text('No video selected'),

                  const SizedBox(height: 8),

                  // Attach button
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
