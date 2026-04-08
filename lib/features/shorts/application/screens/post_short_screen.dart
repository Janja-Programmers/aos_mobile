import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/shorts/navigation/shorts_routes.dart';
import 'package:africaonlinestores/features/shorts/application/screens/post_short/post_short_bottom_panel.dart';
import 'package:africaonlinestores/features/shorts/application/screens/post_short/post_short_controller.dart';
import 'package:africaonlinestores/features/shorts/application/screens/post_short/post_short_picker.dart';
import 'package:africaonlinestores/features/shorts/application/screens/post_short/post_short_top_bar.dart';

import 'package:africaonlinestores/features/shorts/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/application/widgets/upload_progress_overlay.dart';
import 'package:africaonlinestores/features/shorts/application/widgets/video_preview.dart';

class PostShortScreen extends ConsumerStatefulWidget {
  const PostShortScreen({super.key});

  @override
  ConsumerState<PostShortScreen> createState() => _PostShortScreenState();
}

class _PostShortScreenState extends ConsumerState<PostShortScreen> {
  final controller = PostShortController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _upload() async {
    if (controller.videoFile == null) return;

    if (controller.selectedAdId == null) {
      return;
    }

    final notifier = ref.read(uploadOrchestratorProvider.notifier);

    // 🔥 START upload (don’t await)
    await notifier.uploadShort(
      adId: controller.selectedAdId!,
      filePath: controller.videoFile!.path,
      caption: controller.captionController.text.trim(),
      hashtags: controller.hashtags,
    );

    // 🔥 NAVIGATE immediately
    if (context.mounted) ShortsNavigation.toShorts(context);
  }

  @override
  Widget build(BuildContext context) {
    final upload = ref.watch(uploadOrchestratorProvider);
    final hasVideo = controller.videoFile != null;

    return Scaffold(
      body: Stack(
        children: [
          if (hasVideo)
            VideoPreview(file: controller.videoFile!)
          else
            PostShortPicker(
              onPick: () => controller.pickVideo(() => setState(() {})),
            ),

          PostShortTopBar(
            hasVideo: hasVideo,
            onClose: () => Navigator.pop(context),
            onRefresh: () => controller.pickVideo(() => setState(() {})),
            onPost: controller.selectedAdId == null ? null : _upload,
          ),

          if (hasVideo)
            PostShortBottomPanel(
              controller: controller,
              onChanged: () => setState(() {}),
              onHashtagsChanged: (tags) {
                controller.hashtags = tags;
                setState(() {});
              },
            ),

          if (upload.isBusy || upload.isDone || upload.hasError)
            UploadProgressOverlay(upload: upload),
        ],
      ),
    );
  }
}
