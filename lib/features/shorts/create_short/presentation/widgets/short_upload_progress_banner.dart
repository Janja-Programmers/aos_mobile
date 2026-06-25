import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/state/upload_state.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/shared/navigation/shorts_routes.dart';

class ShortUploadProgressBanner extends ConsumerWidget {
  const ShortUploadProgressBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = ref.watch(activeShortUploadSessionProvider);
    if (sessionId == null || sessionId.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final state = ref.watch(postShortControllerProvider(sessionId));
    if (state.status == UploadStatus.idle ||
        state.status == UploadStatus.picked) {
      return const SizedBox.shrink();
    }

    final colors = context.appColors;
    final isDone = state.status == UploadStatus.ready;
    final isFailed = state.status == UploadStatus.failed;
    final progress = state.status == UploadStatus.uploading
        ? state.progress.clamp(0.0, 1.0)
        : state.status == UploadStatus.processing
        ? null
        : isDone
        ? 1.0
        : 0.0;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          color: colors.surface,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isDone && state.shortId != null
                ? () {
                    ShortsNavigation.toShortDetailById(
                      context,
                      shortId: state.shortId!.value,
                    );
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isFailed
                        ? Colors.red.withOpacity(.12)
                        : colors.primary.withOpacity(.12),
                    child: Icon(
                      isDone
                          ? Icons.check_rounded
                          : isFailed
                          ? Icons.error_outline_rounded
                          : Icons.video_library_outlined,
                      color: isFailed ? Colors.red : colors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_titleFor(state), style: context.pStrong),
                        const SizedBox(height: 5),
                        if (progress == null)
                          const LinearProgressIndicator(minHeight: 4)
                        else
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                          ),
                      ],
                    ),
                  ),
                  if (isFailed && state.shortId != null)
                    TextButton(
                      onPressed: () {
                        ref
                            .read(
                              postShortControllerProvider(sessionId).notifier,
                            )
                            .retryProcessingCurrent();
                      },
                      child: const Text('Retry'),
                    )
                  else
                    IconButton(
                      onPressed: () {
                        ref
                                .read(activeShortUploadSessionProvider.notifier)
                                .state =
                            null;
                      },
                      icon: Icon(Icons.close_rounded, color: colors.textMuted),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _titleFor(UploadState state) {
    switch (state.status) {
      case UploadStatus.initializing:
        return 'Preparing short...';
      case UploadStatus.uploading:
        return 'Uploading ${(state.progress * 100).clamp(0, 100).round()}%';
      case UploadStatus.confirming:
        return 'Confirming upload...';
      case UploadStatus.processing:
        return 'Processing video...';
      case UploadStatus.ready:
        return 'Short is ready — tap to view';
      case UploadStatus.failed:
        return state.errorMessage ?? 'Short upload failed';
      case UploadStatus.idle:
      case UploadStatus.picked:
        return 'Short selected';
    }
  }
}
