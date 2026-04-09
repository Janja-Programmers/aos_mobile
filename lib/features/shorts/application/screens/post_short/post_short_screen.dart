import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/shorts/application/controllers/post_short_controller.dart';
import 'package:africaonlinestores/features/shorts/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/application/widgets/post_short/ad_picker_bottom_sheet.dart';
import 'package:africaonlinestores/features/shorts/application/widgets/post_short/post_short_bottom_panel.dart';
import 'package:africaonlinestores/features/shorts/application/widgets/post_short/post_short_picker.dart';
import 'package:africaonlinestores/features/shorts/application/widgets/post_short/post_short_top_bar.dart';
import 'package:africaonlinestores/features/shorts/application/widgets/post_short/upload_progress_overlay.dart';
import 'package:africaonlinestores/features/shorts/application/widgets/post_short/video_preview.dart';

import 'package:africaonlinestores/features/shorts/navigation/shorts_routes.dart';

class PostShortScreen extends ConsumerStatefulWidget {
  const PostShortScreen({super.key});

  @override
  ConsumerState<PostShortScreen> createState() => _PostShortScreenState();
}

class _PostShortScreenState extends ConsumerState<PostShortScreen> {
  final captionController = TextEditingController();

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postShortControllerProvider);
    final controller = ref.read(postShortControllerProvider.notifier);

    final hasVideo = state.videoFile != null;

    // 🔥 navigation listener
    ref.listen(postShortControllerProvider, (prev, next) {
      if (next.isReady) {
        ShortsNavigation.toShorts(context);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // VIDEO / PICKER
          if (hasVideo)
            VideoPreview(file: state.videoFile!)
          else
            PostShortPicker(onPick: controller.pickVideo),

          // TOP BAR
          PostShortTopBar(
            hasVideo: hasVideo,
            onClose: () => Navigator.pop(context),
            onRefresh: controller.pickVideo,
            onPost: state.selectedAdId == null ? null : controller.upload,
          ),

          // BOTTOM PANEL
          if (hasVideo)
            PostShortBottomPanel(
              captionController: captionController,
              selectedAdId: state.selectedAdId,
              onChanged: () {
                controller.setCaption(captionController.text);
              },
              onHashtagsChanged: controller.setHashtags,
              onSelectAd: () => _openAdPicker(controller),
            ),

          // OVERLAY
          if (state.isBusy || state.isReady || state.hasError)
            UploadProgressOverlay(upload: state, onRetry: controller.upload),
        ],
      ),
    );
  }

  void _openAdPicker(PostShortController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (_) {
        return AdPickerBottomSheet(onSelected: controller.setAd);
      },
    );
  }
}
