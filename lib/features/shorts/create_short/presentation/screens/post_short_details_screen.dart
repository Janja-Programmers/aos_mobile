import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/shorts/create_short/application/state/upload_state.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/controllers/post_short_controller.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/selected_media_type.dart';
import 'package:africaonlinestores/features/shorts/shared/navigation/shorts_routes.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/widgets/ad_picker_bottom_sheet.dart';

import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class PostShortDetailsScreen extends ConsumerStatefulWidget {
  final List<SelectedMedia> media;
  final String sessionId;

  const PostShortDetailsScreen({
    super.key,
    required this.media,
    required this.sessionId,
  });

  @override
  ConsumerState<PostShortDetailsScreen> createState() =>
      _PostShortDetailsScreenState();
}

class _PostShortDetailsScreenState
    extends ConsumerState<PostShortDetailsScreen> {
  final captionController = TextEditingController();
  final hashtagController = TextEditingController();

  late final PostShortController controller;
  late final List<SelectedMedia> selectedMedia;

  @override
  void initState() {
    super.initState();

    controller = ref.read(
      postShortControllerProvider(widget.sessionId).notifier,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setMedia(widget.media);
    });

    captionController.addListener(() {
      controller.setCaption(captionController.text.trim());
    });
  }

  @override
  void dispose() {
    captionController.dispose();
    hashtagController.dispose();
    super.dispose();
  }

  // ───────────────────────── BUILD

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postShortControllerProvider(widget.sessionId));

    ref.listen<UploadState>(postShortControllerProvider(widget.sessionId), (
      previous,
      next,
    ) {
      /// 🚀 Move to Shorts immediately when processing starts
      if (next.status == UploadStatus.processing &&
          previous?.status != UploadStatus.processing) {
        if (mounted) {
          ShortsNavigation.toShorts(context);
        }
      }

      /// 🎯 Upload fully completed
      if (next.status == UploadStatus.ready &&
          previous?.status != UploadStatus.ready) {
        ref.read(shortsControllerProvider.notifier).loadInitial();
      }

      /// ❌ Failed
      if (next.status == UploadStatus.failed &&
          previous?.status != UploadStatus.failed) {
        if (mounted) {
          ShowSnack(context, "Upload failed").error();
        }
      }
    });

    final isBusy = switch (state.status) {
      UploadStatus.initializing ||
      UploadStatus.uploading ||
      UploadStatus.confirming ||
      UploadStatus.processing => true,
      _ => false,
    };
    final colors = context.appColors;

    final media = state.primaryMedia;
    final hasMedia = media != null;

    final canPost =
        hasMedia &&
        state.selectedAdId != null &&
        state.caption.trim().isNotEmpty &&
        !state.isBusy;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        centerTitle: true,
        title: Text("New Post", style: context.h5),
      ),
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          // 🧠 MAIN UI (ALWAYS ACTIVE)
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _mediaPreview(state, colors),
                        const SizedBox(height: 14),
                        _caption(colors),
                        const SizedBox(height: 14),
                        _hashtags(colors),
                        const SizedBox(height: 14),
                        _addItems(colors),
                        const SizedBox(height: 14),
                        _selectedAd(state, colors),
                      ],
                    ),
                  ),
                ),

                _postButton(colors, canPost),
              ],
            ),
          ),

          // 🚫 INTERACTION BLOCKER + LOADER
          if (isBusy)
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(strokeWidth: 2),
                        const SizedBox(height: 12),
                        Text(
                          "Uploading...",
                          style: AppTextStylesX(
                            context,
                          ).button.copyWith(color: colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ───────────────────────── MEDIA PREVIEW

  Widget _mediaPreview(UploadState state, AppColorTokens colors) {
    final media = state.primaryMedia;
    if (media == null) return const SizedBox();

    return AspectRatio(
      aspectRatio: 9 / 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(media.file, fit: BoxFit.cover),
      ),
    );
  }

  // ───────────────────────── CAPTION

  Widget _caption(AppColorTokens colors) {
    return TextField(
      controller: captionController,
      maxLines: 6,
      maxLength: 512,
      decoration: InputDecoration(
        hintText:
            "What's on your mind? Describe your post, share a story, or tell people about your product...",
        hintStyle: context.pMuted,
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ───────────────────────── ADS

  Widget _addItems(AppColorTokens colors) {
    return GestureDetector(
      onTap: _openAdPicker,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.add),
            SizedBox(width: 8),
            Text("Add Items"),
            Spacer(),
            Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  void _openAdPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return AdPickerBottomSheet(
          onSelected: (id) {
            controller.setAd(id);
          },
        );
      },
    );
  }

  // ───────────────────────── HASHTAGS

  Widget _hashtags(AppColorTokens colors) {
    return TextField(
      controller: hashtagController,
      onChanged: (v) {
        final tags = v
            .split(RegExp(r'\s+'))
            .where((e) => e.startsWith('#'))
            .toList();

        controller.setHashtags(tags);
      },
      decoration: InputDecoration(
        hintText: "#hashtags",
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ───────────────────────── SELECTED AD

  Widget _selectedAd(UploadState state, AppColorTokens colors) {
    if (state.selectedAdId == null) return const SizedBox();
    return Text("Selected: ${state.selectedAdId}");
  }

  // ───────────────────────── POST BUTTON

  Widget _postButton(AppColorTokens colors, bool canPost) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canPost
              ? () async {
                  await controller.upload();
                }
              : null,
          child: Text(
            "Post",
            style: canPost ? AppTextStylesX(context).button : context.p,
          ),
        ),
      ),
    );
  }
}
