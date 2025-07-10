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
        product?.image != null ? 'https://ownashop.com${product!.image}' : null;
    final videoUrl =
        product?.demoVideo != null
            ? 'https://ownashop.com${product!.demoVideo}'
            : null;

    return Row(
      children: [
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
                  )
                  : const Text('No image selected'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => controller.pickFile(context, isImage: true),
                child: Row(
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Demo Video', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              controller.selectedVideo != null
                  ? Text(
                    'Selected: ${controller.selectedVideo!.path.split('/').last}',
                  )
                  : videoUrl != null
                  ? Text('Video: $videoUrl')
                  : const Text('No video selected'),
              const SizedBox(height: 8),

              ElevatedButton(
                onPressed: () => controller.pickFile(context, isImage: false),
                child: Row(
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
  }
}
