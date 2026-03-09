import 'dart:io';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/widgets/edit_image_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:africaonlinestores/features/ads/ads_create/ui/steps/widgets/action_media_card.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/widgets/media_image_tile.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/widgets/media_video_tile.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/steps/widgets/section_tile.dart';

import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';

class MediaSection extends ConsumerStatefulWidget {
  const MediaSection({super.key});

  @override
  ConsumerState<MediaSection> createState() => _MediaSectionState();
}

class _MediaSectionState extends ConsumerState<MediaSection> {
  bool _uploadingImage = false;
  bool _uploadingVideo = false;

  final picker = ImagePicker();

  // ---------------- UPLOAD IMAGE CORE ----------------
  Future<void> _upload(File file) async {
    if (_uploadingImage) return;

    final draft = ref.read(adDraftControllerProvider).value;
    if (draft == null) return;
    if (draft.images.length >= 4) return;

    setState(() => _uploadingImage = true);

    try {
      await ref
          .read(adDraftControllerProvider.notifier)
          .uploadAndAddImage(file);
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

    final x = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (x == null) return;

    await _upload(File(x.path));
  }

  // ---------------- UPLOAD MULTIPLE ----------------
  Future<void> _uploadPhotos() async {
    final draft = ref.read(adDraftControllerProvider).value;
    if (draft == null || draft.images.length >= 4) return;

    final files = await picker.pickMultiImage(imageQuality: 80);
    if (files.isEmpty) return;

    for (final f in files.take(4 - draft.images.length)) {
      await _upload(File(f.path));
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

    final x = await picker.pickVideo(source: ImageSource.camera);
    if (x == null) return;

    await _uploadVideoFile(File(x.path));
  }

  Future<void> _uploadVideoFromGallery() async {
    final draft = ref.read(adDraftControllerProvider).value;
    if (draft == null) return;
    if (draft.videoUrl != null) return;

    final x = await picker.pickVideo(source: ImageSource.gallery);
    if (x == null) return;

    await _uploadVideoFile(File(x.path));
  }

  Future<void> _uploadVideoFile(File file) async {
    if (_uploadingVideo) return;

    setState(() => _uploadingVideo = true);

    await ref.read(adDraftControllerProvider.notifier).uploadAndSetVideo(file);

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
        const SectionTitle(title: "Photos *"),
        const SizedBox(height: 12),

        if (draft.images.isEmpty)
          _uploadingImage
              ? const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                )
              : Row(
                  children: [
                    Expanded(
                      child: ActionMediaCard(
                        icon: Icons.upload_outlined,
                        label: 'Upload Photos',
                        onTap: _uploadingImage ? null : _uploadPhotos,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ActionMediaCard(
                        icon: Icons.camera_alt_outlined,
                        label: 'Take Photo',
                        onTap: _uploadingImage ? null : _takePhoto,
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
                    onUpload: _uploadingImage ? () {} : _uploadPhotos,
                    onTakePhoto: _uploadingImage ? () {} : _takePhoto,
                  );
                }

                // Shift index if AddTile exists
                final imageIndex = draft.images.length < 4 ? i - 1 : i;

                final img = draft.images[imageIndex];

                return MediaImageTile(
                  image: img,
                  isPrimary: i == 0,
                  showPrimaryOption: i != 0,
                  onDelete: _uploadingImage
                      ? null
                      : () => ref
                            .read(adDraftControllerProvider.notifier)
                            .removeImage(i),
                  onMarkPrimary: _uploadingImage ? null : () => _markPrimary(i),
                  onEdit: _uploadingImage
                      ? null
                      : () async {
                          final imageUrl = img.url;
                          final fullUrl = buildFileUrl(imageUrl);

                          if (fullUrl == null) return;

                          // Download image first
                          final response = await http.get(Uri.parse(fullUrl));
                          if (response.statusCode != 200) return;

                          final dir = await getTemporaryDirectory();
                          final file = File('${dir.path}/edit_temp.png');
                          await file.writeAsBytes(response.bodyBytes);

                          // Open editor
                          final editedFile = await Navigator.push<File?>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditImagePage(file: file),
                            ),
                          );

                          // Replace image at index
                          await ref
                              .read(adDraftControllerProvider.notifier)
                              .replaceImageAt(i, editedFile!);
                        },
                );
              },
            ),
          ),

        const SizedBox(height: 28),

        // ===================== VIDEO =====================
        const SectionTitle(title: 'Videos'),
        const SizedBox(height: 12),

        if (draft.videoUrl == null)
          Row(
            children: [
              Expanded(
                child: ActionMediaCard(
                  icon: Icons.upload_outlined,
                  label: 'Upload Video',
                  onTap: _uploadVideoFromGallery,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: ActionMediaCard(
                  icon: Icons.video_library_outlined,
                  label: 'Take Video',
                  onTap: _takeVideo,
                ),
              ),
            ],
          )
        else
          MediaVideoTile(
            videoUrl: draft.videoUrl!,
            onDelete: () =>
                ref.read(adDraftControllerProvider.notifier).clearVideo(),
          ),

        const SizedBox(height: 12),
      ],
    );
  }
}
