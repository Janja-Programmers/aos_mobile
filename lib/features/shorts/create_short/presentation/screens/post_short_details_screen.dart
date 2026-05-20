import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_color_tokens.dart';
import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/enums/selected_media_type.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/state/upload_state.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/state/post_category_options.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/widgets/ad_picker_bottom_sheet.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/controllers/post_short_controller.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/helpers/post_short_media_helpers.dart';

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
  late final ProviderSubscription<UploadState> _uploadSubscription;

  Uint8List? _thumbnail;

  PostCategoryOption _selectedCategory = postCategoriesData.first;

  @override
  void initState() {
    super.initState();

    final provider = postShortControllerProvider(widget.sessionId);

    controller = ref.read(provider.notifier);

    _uploadSubscription = ref.listenManual<UploadState>(provider, (
      previous,
      next,
    ) {
      if (next.status == UploadStatus.processing &&
          previous?.status != UploadStatus.processing) {
        if (mounted) {
          context.goNamed(AppRoutes.nFeeds, extra: 0);
        }
      }

      if (next.status == UploadStatus.ready &&
          previous?.status != UploadStatus.ready) {
        ref.read(shortsControllerProvider.notifier).loadInitial();
      }

      if (next.status == UploadStatus.failed &&
          previous?.status != UploadStatus.failed) {
        if (mounted) {
          ShowSnack(context, "Upload failed").error();
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setMedia(widget.media);
      _generateThumbnail();
    });

    captionController.addListener(() {
      controller.setCaption(captionController.text.trim());
    });
  }

  @override
  void dispose() {
    _uploadSubscription.close();
    captionController.dispose();
    hashtagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postShortControllerProvider(widget.sessionId));

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

    final hasSelectedAd =
        state.selectedAdId != null && state.selectedAdId!.trim().isNotEmpty;

    final requiresAd = _selectedCategory.requiresAd;

    final canPost =
        hasMedia &&
        state.caption.trim().isNotEmpty &&
        (!requiresAd || hasSelectedAd) &&
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
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _mediaPreview(state, colors),
                        const SizedBox(height: 14),

                        _categorySelector(colors),
                        const SizedBox(height: 10),

                        _categoryDescriptionCard(colors),
                        const SizedBox(height: 14),

                        _caption(colors),
                        const SizedBox(height: 14),

                        _hashtags(colors),
                        const SizedBox(height: 14),

                        if (requiresAd) ...[
                          _businessProductSection(state, colors),
                          const SizedBox(height: 14),
                        ],
                      ],
                    ),
                  ),
                ),
                _postFooter(colors, canPost),
              ],
            ),
          ),

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

  Widget _mediaPreview(UploadState state, AppColorTokens colors) {
    final media = state.primaryMedia;
    if (media == null) return const SizedBox();

    return SizedBox(
      height: 96,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _thumbnail == null
                ? Container(
                    width: 84,
                    height: 96,
                    color: colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Stack(
                    children: [
                      Image.memory(
                        _thumbnail!,
                        width: 84,
                        height: 96,
                        fit: BoxFit.cover,
                      ),
                      Positioned.fill(
                        child: Container(
                          alignment: Alignment.center,
                          color: colors.black.withOpacity(.35),
                          child: Icon(
                            Icons.play_circle_outline_rounded,
                            color: colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 84,
            height: 96,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.add_rounded, color: colors.textMuted, size: 30),
          ),
        ],
      ),
    );
  }

  Future<void> _generateThumbnail() async {
    final file = widget.media.first.file;
    final thumb = await PostShortMediaHelpers.generateVideoThumbnail(file);

    if (!mounted) return;

    setState(() {
      _thumbnail = thumb;
    });
  }

  Widget _categorySelector(AppColorTokens colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: 'Content Mode ',
            style: context.pStrong,
            children: [
              TextSpan(
                text: '*',
                style: context.pStrong.copyWith(color: colors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: postCategoriesData.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, index) {
              final category = postCategoriesData[index];
              final isSelected = category.id == _selectedCategory.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });

                  if (!category.requiresAd) {
                    controller.clearAd();
                  }

                  controller.setContentMode(category.contentMode);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.primary : colors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category.icon,
                        size: 14,
                        color: isSelected ? colors.white : colors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category.label,
                        style: context.small.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSelected ? colors.white : colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _categoryDescriptionCard(AppColorTokens colors) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.primary.withOpacity(.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              _selectedCategory.description,
              style: context.small.copyWith(
                color: colors.textMuted,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary),
        ),
      ),
    );
  }

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
        hintText: "#hashtags (e.g. #fashion #deals #trending)",
        hintStyle: context.pMuted,
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary),
        ),
      ),
    );
  }

  Widget _businessProductSection(UploadState state, AppColorTokens colors) {
    final hasSelectedAd =
        state.selectedAdId != null && state.selectedAdId!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasSelectedAd ? '1/1 product tagged' : '0/1 product tagged',
          style: context.small.copyWith(
            color: hasSelectedAd ? colors.textMuted : colors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        if (hasSelectedAd)
          _selectedAdCard(state, colors)
        else
          _addProductCard(colors),
      ],
    );
  }

  Widget _addProductCard(AppColorTokens colors) {
    return GestureDetector(
      onTap: _openAdPicker,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.primary),
        ),
        child: Row(
          children: [
            Icon(Icons.sell_outlined, color: colors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Tag a product (required)",
                style: context.pStrong.copyWith(color: colors.primary),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _selectedAdCard(UploadState state, AppColorTokens colors) {
    final selectedAdThumbnail = state.short?.ad?.thumbnail;
    final selectedAdId = state.selectedAdId;

    if (selectedAdId == null || selectedAdId.trim().isEmpty) {
      return const SizedBox();
    }

    final imageUrl =
        selectedAdThumbnail == null || selectedAdThumbnail.trim().isEmpty
        ? null
        : buildFileUrl(selectedAdThumbnail);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.black.withOpacity(.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 54,
              height: 54,
              color: colors.surface,
              child: imageUrl == null
                  ? Icon(Icons.image_outlined, color: colors.primary, size: 24)
                  : Image.network(
                      imageUrl,
                      width: 54,
                      height: 54,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.broken_image_outlined,
                        color: colors.primary,
                        size: 24,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _openAdPicker,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Product tagged ✓",
                    style: context.pStrong,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    selectedAdId,
                    style: context.small.copyWith(color: colors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Tap to change product",
                    style: context.small.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: controller.clearAd,
            icon: Icon(Icons.close_rounded, color: colors.textMuted),
          ),
        ],
      ),
    );
  }

  void _openAdPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Material(
          color: context.appColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: AdPickerBottomSheet(
            onSelected: (id) {
              controller.setAd(id);
            },
          ),
        );
      },
    );
  }

  Widget _postFooter(AppColorTokens colors, bool canPost) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
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
          const SizedBox(height: 8),
          Text(
            "I confirm that there are no private messages in my content",
            textAlign: TextAlign.center,
            style: context.small.copyWith(color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}
