import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:africaonlinestores/core/routing/app_routes.dart';
import 'package:africaonlinestores/features/ads/providers/ad_draft_controller.dart';
import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/utils/file_url.dart';
import 'package:africaonlinestores/features/ads/ui/widgets/picker_field.dart';
import 'package:africaonlinestores/core/utils/app_snack.dart';

class BasicStep extends ConsumerStatefulWidget {
  const BasicStep({super.key});

  @override
  ConsumerState<BasicStep> createState() => _BasicStepState();
}

class _BasicStepState extends ConsumerState<BasicStep> {
  final _titleCtrl = TextEditingController();
  bool _initialised = false;
  bool _uploadingImage = false;
  bool _uploadingVideo = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (x == null) return;
    setState(() => _uploadingImage = true);
    final ctrl = ref.read(adDraftControllerProvider.notifier);
    final res = await ctrl.uploadAndAddImage(File(x.path));
    setState(() => _uploadingImage = false);
    if (res.isLeft && mounted) {
      ShowSnack(context, res.leftOrNull!.message).error();
    }
  }

  Future<void> _pickAndUploadVideo() async {
    final picker = ImagePicker();
    final x = await picker.pickVideo(source: ImageSource.gallery);
    if (x == null) return;
    setState(() => _uploadingVideo = true);
    final ctrl = ref.read(adDraftControllerProvider.notifier);
    final res = await ctrl.uploadAndSetVideo(File(x.path));
    setState(() => _uploadingVideo = false);
    if (res.isLeft && mounted) {
      ShowSnack(context, res.leftOrNull!.message).error();
    }
  }

  @override
  Widget build(BuildContext context) {
    final draftAsync = ref.watch(adDraftControllerProvider);
    final draft = draftAsync.maybeWhen(data: (v) => v, orElse: () => null);
    if (draft == null) return const SizedBox.shrink();

    if (!_initialised) {
      _initialised = true;
      _titleCtrl.text = draft.title;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      children: [
        Text(
          'Title',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _titleCtrl,
          maxLength: 80,
          onChanged: (v) =>
              ref.read(adDraftControllerProvider.notifier).updateTitle(v),
          decoration: const InputDecoration(
            hintText: 'Provide a descriptive title',
          ),
        ),
        const SizedBox(height: 10),
        PickerField(
          label: 'Location',
          required: true,
          value: draft.locationLabel,
          leading: const Icon(Icons.place_outlined),
          onTap: () async {
            final res = await context.push<Map<String, dynamic>>(
              AppRoutes.selectLocation,
            );
            if (res == null) return;
            final id = (res['id'] ?? '').toString();
            final label = (res['label'] ?? '').toString();
            if (id.isEmpty) return;
            ref
                .read(adDraftControllerProvider.notifier)
                .setLocation(id: id, label: label);
          },
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Text(
                'Photos',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            if (_uploadingImage)
              const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            TextButton.icon(
              onPressed: _uploadingImage ? null : _pickAndUploadImage,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _ImagesStrip(
          images: draft.images,
          onSetPrimary: (i) =>
              ref.read(adDraftControllerProvider.notifier).setPrimaryImage(i),
          onRemove: (i) =>
              ref.read(adDraftControllerProvider.notifier).removeImage(i),
        ),
        const SizedBox(height: 18),
        Text(
          'Video',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: draft.videoUrl == null
                  ? Text(
                      'Optional',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    )
                  : Text(
                      'Selected',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
            ),
            if (_uploadingVideo)
              const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            if (draft.videoUrl == null)
              TextButton.icon(
                onPressed: _uploadingVideo ? null : _pickAndUploadVideo,
                icon: const Icon(Icons.video_call_outlined),
                label: const Text('Add'),
              )
            else
              TextButton.icon(
                onPressed: () =>
                    ref.read(adDraftControllerProvider.notifier).clearVideo(),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove'),
              ),
          ],
        ),
        const SizedBox(height: 18),
        PickerField(
          label: 'Category',
          required: true,
          value: draft.categoryLabel,
          leading: const Icon(Icons.category_outlined),
          onTap: () async {
            final res = await context.push<Map<String, dynamic>>(
              AppRoutes.selectCategory,
            );
            if (res == null) return;
            final id = (res['id'] ?? '').toString();
            final label = (res['label'] ?? '').toString();
            if (id.isEmpty) return;
            ref
                .read(adDraftControllerProvider.notifier)
                .setCategory(id: id, label: label);
          },
        ),
      ],
    );
  }
}

class _ImagesStrip extends StatelessWidget {
  const _ImagesStrip({
    required this.images,
    required this.onSetPrimary,
    required this.onRemove,
  });

  final List<AdMediaImage> images;
  final ValueChanged<int> onSetPrimary;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Text(
        'Add at least one photo.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
      );
    }

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final img = images[i];
          final url = buildFileUrl(img.url);
          final isPrimary = img.isPrimary;

          return GestureDetector(
            onTap: () => onSetPrimary(i),
            onLongPress: () => onRemove(i),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 92,
                    width: 92,
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: url == null
                        ? const Icon(Icons.image_not_supported_outlined)
                        : Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const Icon(Icons.broken_image_outlined),
                          ),
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: InkWell(
                    onTap: () => onRemove(i),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (isPrimary)
                  Positioned(
                    left: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Primary',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
