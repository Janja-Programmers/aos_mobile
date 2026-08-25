import 'dart:io';

import 'package:africaonlinestores/core/media/application/media_services_provider.dart';
import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/widgets/action_media_card.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/widgets/edit_image/edit_image_screen.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/widgets/media_image_tile.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/widgets/media_video_tile.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/widgets/section_tile.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';
import 'package:africaonlinestores/shared/utils/url_to_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MediaSection extends ConsumerStatefulWidget {
  const MediaSection({super.key});

  @override
  ConsumerState<MediaSection> createState() => _MediaSectionState();
}

class _MediaSectionState extends ConsumerState<MediaSection> {
  bool _uploadingImage = false;
  bool _uploadingVideo = false;

  final Map<String, File> _localEditedPreviews = {};

  // ---------------- UPLOAD IMAGE CORE ----------------
  Future<void> _upload(AcquiredMedia media) async {
    if (_uploadingImage) {
      await media.discard();
      return;
    }

    final draft = ref.read(adDraftControllerProvider).value;
    if (draft == null || draft.images.length >= 4) {
      await media.discard();
      return;
    }

    setState(() => _uploadingImage = true);

    try {
      await ref
          .read(adDraftControllerProvider.notifier)
          .uploadAndAddImage(media);
    } finally {
      if (mounted) {
        setState(() => _uploadingImage = false);
      }
    }
  }

  // ---------------- TAKE PHOTO ----------------
  Future<void> _takePhoto() async {
    final draft = ref.read(adDraftControllerProvider).value;
    if (draft == null || draft.images.length >= 4) return;

    final media = await ref
        .read(mediaAcquisitionServiceProvider)
        .captureImage(context, useCase: MediaUseCase.adImage);
    if (media == null) return;
    if (!mounted) {
      await media.discard();
      return;
    }

    await _upload(media);
  }

  // ---------------- UPLOAD MULTIPLE ----------------
  Future<void> _uploadPhotos() async {
    final draft = ref.read(adDraftControllerProvider).value;
    if (draft == null || draft.images.length >= 4) return;

    final files = await ref
        .read(mediaAcquisitionServiceProvider)
        .pickImages(
          useCase: MediaUseCase.adImage,
          maxItems: 4 - draft.images.length,
        );
    if (files.isEmpty) return;
    if (!mounted) {
      for (final file in files) {
        await file.discard();
      }
      return;
    }

    for (final file in files) {
      await _upload(file);
    }
  }

  // ---------------- MARK PRIMARY ----------------
  void _markPrimary(int index) {
    final draft = ref.read(adDraftControllerProvider).value;
    if (draft == null) return;

    // If already primary do nothing
    if (index == 0) return;

    final images = [...draft.images];

    final selected = images.removeAt(index);
    images.insert(0, selected);

    // Replace entire list (clean reorder)
    ref.read(adDraftControllerProvider.notifier).replaceImages(images);
  }

  // ---------------- VIDEO ----------------

  Future<void> _takeVideo() async {
    final draft = ref.read(adDraftControllerProvider).value;
    if (draft == null) return;
    if (draft.videoUrl != null) return;

    final media = await ref
        .read(mediaAcquisitionServiceProvider)
        .captureVideo(context, useCase: MediaUseCase.adVideo);
    if (media == null) return;
    if (!mounted) {
      await media.discard();
      return;
    }

    await _uploadVideoFile(media);
  }

  Future<void> _uploadVideoFromGallery() async {
    final draft = ref.read(adDraftControllerProvider).value;
    if (draft == null) return;
    if (draft.videoUrl != null) return;

    final media = await ref
        .read(mediaAcquisitionServiceProvider)
        .pickVideo(useCase: MediaUseCase.adVideo);
    if (media == null) return;
    if (!mounted) {
      await media.discard();
      return;
    }

    await _uploadVideoFile(media);
  }

  Future<void> _uploadVideoFile(AcquiredMedia media) async {
    if (_uploadingVideo) {
      await media.discard();
      return;
    }

    setState(() => _uploadingVideo = true);

    await ref.read(adDraftControllerProvider.notifier).uploadAndSetVideo(media);

    if (mounted) {
      setState(() => _uploadingVideo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(adDraftControllerProvider).value;
    if (draft == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===================== PHOTOS =====================
        const SectionTitle(title: 'Photos *'),
        const SizedBox(height: 12),
        if (draft.images.isEmpty)
          Row(
            children: [
              Expanded(
                child: ActionMediaCard(
                  icon: Icons.upload_outlined,
                  label: 'Upload Photos',
                  loading: _uploadingImage,
                  onTap: _uploadPhotos,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionMediaCard(
                  icon: Icons.camera_alt_outlined,
                  label: 'Take Photo',
                  loading: _uploadingImage,
                  onTap: _takePhoto,
                ),
              ),
            ],
          )
        else
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemCount:
                  draft.images.length + (draft.images.length < 4 ? 1 : 0),
              itemBuilder: (_, i) {
                if (draft.images.length < 4 && i == 0) {
                  return AddPhotoTile(
                    loading: _uploadingImage,
                    onUpload: _uploadPhotos,
                    onTakePhoto: _takePhoto,
                  );
                }

                // Shift index if AddTile exists
                final imageIndex = draft.images.length < 4 ? i - 1 : i;

                final img = draft.images[imageIndex];

                return MediaImageTile(
                  image: img,
                  localPreviewFile: _localEditedPreviews[img.fileId],
                  isPrimary: imageIndex == 0,
                  showPrimaryOption: imageIndex != 0,
                  onDelete: _uploadingImage
                      ? null
                      : () => ref
                            .read(adDraftControllerProvider.notifier)
                            .removeImage(imageIndex),
                  onMarkPrimary: _uploadingImage
                      ? null
                      : () => _markPrimary(imageIndex),
                  onEdit: () async {
                    final file = await urlToFile(img.url);

                    if (!context.mounted) return;

                    final edited = await Navigator.push<File>(
                      context,
                      MaterialPageRoute<File>(
                        builder: (_) => EditImageScreen(
                          file: file,
                          fileId: img.fileId,
                          index: imageIndex,
                        ),
                      ),
                    );

                    if (edited == null) return;

                    setState(() {
                      _localEditedPreviews[img.fileId] = edited;
                    });

                    await ref
                        .read(adDraftControllerProvider.notifier)
                        .replaceImageAt(imageIndex, edited);
                  },
                );
              },
            ),
          ),

        const SizedBox(height: 28),

        // ===================== VIDEO =====================
        const SectionTitle(title: 'Videos'),
        const SizedBox(height: 12),

        if (draft.videoUrl == null || draft.videoUrl!.isEmpty)
          Row(
            children: [
              Expanded(
                child: ActionMediaCard(
                  icon: Icons.upload_outlined,
                  label: 'Upload Video',
                  loading: _uploadingVideo,
                  onTap: _uploadVideoFromGallery,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionMediaCard(
                  icon: Icons.video_library_outlined,
                  label: 'Take Video',
                  loading: _uploadingVideo,
                  onTap: _takeVideo,
                ),
              ),
            ],
          )
        else
          MediaVideoTile(
            key: ValueKey(draft.videoUrl),
            videoUrl: draft.videoUrl!,
            onDelete: () =>
                ref.read(adDraftControllerProvider.notifier).clearVideo(),
          ),

        const SizedBox(height: 12),
      ],
    );
  }
}
