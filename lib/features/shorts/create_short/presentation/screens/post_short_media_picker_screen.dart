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
  MediaTab currentTab = MediaTab.video;

  List<SelectedMedia> selectedMedia = [];
  final sessionId = UniqueKey().toString();

  bool get hasSelection => selectedMedia.isNotEmpty;

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
      behavior: HitTestBehavior.opaque,
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

  Future<void> _pickMedia() async {
    final file = await MediaHelper.pickVideoWithChoice(context);

    if (file == null) return;

    setState(() {
      selectedMedia = [SelectedMedia(file, MediaType.video)];
    });
  }

  Widget _mediaPreview(AppColorTokens colors) {
    final file = selectedMedia.first.file;

    return Stack(
      fit: StackFit.expand,
      children: [
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

        PostShortMediaWidgets.bottomGradient(colors),
      ],
    );
  } // ───────────────────────── TABS

  Widget _bottomTabs(AppColorTokens colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [_tabItem("Video", MediaTab.video, colors)],
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
                    "Video selected",
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
                itemCount: selectedMedia.length,
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
    if (index >= selectedMedia.length) {
      return const SizedBox.shrink();
    }

    final item = selectedMedia[index];
    final file = item.file;

    return Padding(
      padding: const EdgeInsets.only(right: 12, top: 8),
      child: SizedBox(
        width: 78,
        height: 78,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FutureBuilder(
                  key: ValueKey(file.path),
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
            ),

            /// VIDEO ICON OVERLAY
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                width: 70,
                height: 70,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.black.withOpacity(.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.videocam, color: colors.white, size: 22),
              ),
            ),

            /// REMOVE BUTTON
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    if (index < selectedMedia.length) {
                      selectedMedia.removeAt(index);
                    }
                  });
                },
                child: Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
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
      ),
    );
  }

  String _tabMessage() {
    switch (currentTab) {
      case MediaTab.video:
        return "Tap to pick/upload video";
    }
  }

  IconData _tabIcon() {
    switch (currentTab) {
      case MediaTab.video:
        return Icons.videocam_outlined;
    }
  }

  // ───────────────────────── PICK LOGIC

  void setPickedVideo(SelectedMedia video) {
    setState(() {
      selectedMedia = [video];
    });
  }

  void _goNext() {
    if (!hasSelection) return;

    final pickedVideo = selectedMedia.first;

    final sessionId = const Uuid().v4();

    ShortsNavigation.toPostShortDetails(
      context,
      sessionId: sessionId,
      media: [pickedVideo],
    );
  }
}
