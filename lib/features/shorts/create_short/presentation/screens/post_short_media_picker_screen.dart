import 'package:africaonlinestores/features/shorts/shared/domain/selected_media_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/files/helpers/media_helper.dart';
import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/shorts/shared/navigation/shorts_routes.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/helpers/enums.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/helpers/post_short_media_helpers.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/widgets/post_short_media_widgets.dart';
import 'package:uuid/uuid.dart';

class PostShortMediaPickerScreen extends ConsumerStatefulWidget {
  const PostShortMediaPickerScreen({super.key});

  @override
  ConsumerState<PostShortMediaPickerScreen> createState() =>
      _PostShortMediaPickerScreenState();
}

class _PostShortMediaPickerScreenState
    extends ConsumerState<PostShortMediaPickerScreen> {
  MediaTab currentTab = MediaTab.album;

  List<SelectedMedia> selectedMedia = [];
  final sessionId = UniqueKey().toString();

  bool get hasSelection => selectedMedia.isNotEmpty;

  static const maxImages = 5;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(colors),

            Expanded(
              child: Stack(
                children: [
                  _pickerArea(colors),

                  if (hasSelection) _previewStrip(colors),
                ],
              ),
            ),

            _bottomTabs(colors),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── TOP BAR

  Widget _topBar(AppColorTokens colors) {
    final hasSelection = selectedMedia.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close, color: colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          GestureDetector(
            onTap: hasSelection ? _goNext : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: hasSelection
                    ? colors.primary.withOpacity(.85)
                    : colors.border,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Next",
                style: context.p.copyWith(color: colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── CENTER AREA
  Widget _pickerArea(AppColorTokens colors) {
    if (!hasSelection) {
      return _emptyPicker(colors);
    }

    return _mediaPreview(colors);
  }

  Widget _emptyPicker(AppColorTokens colors) {
    return GestureDetector(
      onTap: _pickMedia,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_tabIcon(), size: 54, color: colors.white.withOpacity(.4)),

            const SizedBox(height: 12),

            Text(
              _tabMessage(),
              style: context.pStrong.copyWith(
                color: colors.white.withOpacity(.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mediaPreview(AppColorTokens colors) {
    final item = selectedMedia.first;
    final isVideo = item.type == MediaType.video;
    final file = item.file;

    return GestureDetector(
      onTap: _pickMedia,
      child: Stack(
        fit: StackFit.expand,
        children: [
          /// IMAGE
          if (!isVideo) Image.file(file, fit: BoxFit.cover),

          /// VIDEO
          if (isVideo)
            FutureBuilder(
              future: PostShortMediaHelpers.generateVideoThumbnail(file),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    color: colors.black,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                return Image.memory(snapshot.data!, fit: BoxFit.cover);
              },
            ),

          /// VIDEO ICON
          if (isVideo)
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.black.withOpacity(.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.videocam, color: colors.white, size: 28),
              ),
            ),

          /// MULTI IMAGE COUNT
          if (!isVideo && selectedMedia.length > 1)
            Positioned(
              top: 12,
              right: 12,
              child: PostShortMediaWidgets.countBadge(
                colors,
                selectedMedia.length,
                context.p.copyWith(color: colors.white),
              ),
            ),

          /// GRADIENT
          PostShortMediaWidgets.bottomGradient(colors),
        ],
      ),
    );
  }

  // ───────────────────────── TABS

  Widget _bottomTabs(AppColorTokens colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _tabItem("Album", MediaTab.album, colors),
          _tabItem("Photo", MediaTab.photo, colors),
          _tabItem("Video", MediaTab.video, colors),
        ],
      ),
    );
  }

  Widget _tabItem(String label, MediaTab tab, colors) {
    final active = currentTab == tab;

    return GestureDetector(
      onTap: () {
        setState(() {
          currentTab = tab;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: active ? colors.white : colors.white.withOpacity(.5),
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          if (active)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: colors.white,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _previewStrip(AppColorTokens colors) {
    final item = selectedMedia.first;
    final isVideo = item.type == MediaType.video;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: colors.black.withOpacity(.95),
          border: Border(top: BorderSide(color: colors.border)),
        ),
        child: Column(
          children: [
            /// selection count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text(
                    isVideo
                        ? "1 video selected"
                        : "${selectedMedia.length} selected",
                    style: context.p.copyWith(
                      color: colors.white.withOpacity(.7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            /// thumbnails
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: isVideo ? 1 : selectedMedia.length,
                itemBuilder: (_, index) {
                  return _previewItem(index, colors);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewItem(int index, AppColorTokens colors) {
    final item = selectedMedia[index];
    final isVideo = item.type == MediaType.video;
    final file = item.file;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          /// IMAGE THUMB
          if (!isVideo)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(file, width: 70, height: 70, fit: BoxFit.cover),
            ),

          /// VIDEO THUMB
          if (isVideo)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FutureBuilder(
                future: PostShortMediaHelpers.generateVideoThumbnail(file),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                      width: 70,
                      height: 70,
                      color: colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  return Image.memory(
                    snapshot.data!,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),

          /// VIDEO ICON
          if (isVideo)
            Positioned.fill(
              child: Container(
                alignment: Alignment.center,
                color: colors.black.withOpacity(.4),
                child: Icon(Icons.videocam, color: colors.white, size: 22),
              ),
            ),

          /// REMOVE BUTTON
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedMedia.removeAt(index);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.white),
                ),
                child: Icon(Icons.close, size: 16, color: colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _tabMessage() {
    switch (currentTab) {
      case MediaTab.album:
        return "Tap to select from album";

      case MediaTab.photo:
        return "Tap to pick/upload multiple photos";

      case MediaTab.video:
        return "Tap to pick/upload video";
    }
  }

  IconData _tabIcon() {
    switch (currentTab) {
      case MediaTab.album:
        return Icons.collections_outlined;

      case MediaTab.photo:
        return Icons.photo_library_outlined;

      case MediaTab.video:
        return Icons.videocam_outlined;
    }
  }

  // ───────────────────────── PICK LOGIC
  Future<void> _pickMedia() async {
    if (currentTab == MediaTab.video) {
      final file = await MediaHelper.pickVideoWithChoice(context);

      if (file == null) return;

      setState(() {
        selectedMedia
          ..clear()
          ..add(SelectedMedia(file, MediaType.video));
      });

      return;
    }

    /// enforce image limit
    if (selectedMedia.length >= maxImages) return;

    final file = await MediaHelper.pickImageFromGallery();

    if (file == null) return;

    setState(() {
      selectedMedia.add(SelectedMedia(file, MediaType.image));
    });
  }

  void _goNext() {
    if (!hasSelection) return;

    final sessionId = const Uuid().v4();

    ShortsNavigation.toPostShortDetails(
      context,
      media: selectedMedia,
      sessionId: sessionId,
    );
  }
}
