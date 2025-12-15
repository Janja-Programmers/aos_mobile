import 'dart:io';

import 'package:flutter/material.dart';

import '/core/constants/colors.dart';
import '/features/product/data/product_model.dart';

import '../controllers/add_item_controller.dart';

class ImageVideoPickerSection extends StatelessWidget {
  final AddItemController controller;
  final ProductModel? product;

  const ImageVideoPickerSection({
    super.key,
    required this.controller,
    required this.product,
  });

  Widget _buildImagePreview(String? imageUrl, File? localFile) {
    // 1️⃣ Local file (if picked)
    if (localFile != null) {
      return Image.file(localFile, fit: BoxFit.cover, width: 100, height: 100);
    }

    // 2️⃣ Remote file (ensure it’s not just base URL)
    if (imageUrl != null &&
        Uri.tryParse(imageUrl)?.isAbsolute == true &&
        imageUrl != 'https://africaonlinestores.com') {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        errorBuilder:
            (_, _, _) => const Text(
              'Invalid image',
              style: TextStyle(color: Colors.grey),
            ),
      );
    }

    // 3️⃣ Nothing valid — show fallback
    return const Text(
      'No image selected',
      style: TextStyle(color: Colors.grey),
    );
  }

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

    final isLoading = controller.isPickingImage || controller.isPickingVideo;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          children: [
            // 🖼️ IMAGE SECTION
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Image', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),

                  // Image preview
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade100,
                    ),
                    child: Center(
                      child: _buildImagePreview(
                        imageUrl,
                        controller.selectedImage,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Attach button
                  isLoading
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : ElevatedButton.icon(
                        onPressed:
                            isLoading
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
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Attach'),
                      ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // 🎥 VIDEO SECTION
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Demo Video',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),

                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade100,
                    ),
                    child: Center(
                      child:
                          controller.selectedVideo != null || videoUrl != null
                              ? const Icon(Icons.videocam, size: 40)
                              : const Text(
                                'No video selected',
                                style: TextStyle(color: Colors.grey),
                              ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  isLoading
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : ElevatedButton.icon(
                        onPressed:
                            isLoading
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
                        icon: const Icon(Icons.video_file),
                        label: const Text('Attach'),
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
