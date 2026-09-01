import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/state/upload_state.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/shared/navigation/shorts_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShortUploadProgressBanner extends ConsumerWidget {
  const ShortUploadProgressBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = ref.watch(activeShortUploadSessionProvider);
    if (sessionId == null || sessionId.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final provider = postShortControllerProvider(sessionId);
    final state = ref.watch(provider);
    if (state.status == UploadStatus.idle ||
        state.status == UploadStatus.picked) {
      return const SizedBox.shrink();
    }

    final colors = context.appColors;
    final isDone = state.status == UploadStatus.ready;
    final isFailed = state.status == UploadStatus.failed;
    final isUploading = state.status == UploadStatus.uploading;
    final canCancel = state.status == UploadStatus.initializing || isUploading;
    final transferActive = canCancel || state.status == UploadStatus.confirming;
    final filename = _filename(state);
    final progress = isUploading
        ? state.progress.clamp(0.0, 1.0).toDouble()
        : isDone
        ? 1.0
        : null;

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(20),
              color: colors.surface,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: isDone && state.shortId != null
                    ? () => ShortsNavigation.toShortDetailById(
                        context,
                        shortId: state.shortId!.value,
                      )
                    : null,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _StatusDisc(
                        progress: progress,
                        isDone: isDone,
                        isFailed: isFailed,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              _titleFor(state),
                              style: context.pStrong.copyWith(
                                color: isDone
                                    ? colors.success
                                    : isFailed
                                    ? Theme.of(context).colorScheme.error
                                    : null,
                              ),
                            ),
                            if (filename.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 2),
                              Text(
                                filename,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.p.copyWith(
                                  color: colors.textMuted,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress,
                              minHeight: 5,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            if (canCancel) ...<Widget>[
                              const SizedBox(height: 6),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(48, 32),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () =>
                                    ref.read(provider.notifier).cancelUpload(),
                                child: const Text('Cancel upload'),
                              ),
                            ] else if (isFailed) ...<Widget>[
                              const SizedBox(height: 6),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(48, 32),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: state.shortId != null
                                    ? () => ref
                                          .read(provider.notifier)
                                          .retryProcessingCurrent()
                                    : () =>
                                          ref.read(provider.notifier).upload(),
                                child: Text(
                                  state.shortId != null
                                      ? 'Retry'
                                      : 'Retry upload',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: isDone
                            ? 'Dismiss upload complete message'
                            : 'Dismiss upload message',
                        onPressed: transferActive
                            ? null
                            : () {
                                ref
                                        .read(
                                          activeShortUploadSessionProvider
                                              .notifier,
                                        )
                                        .state =
                                    null;
                              },
                        icon: Icon(
                          Icons.close_rounded,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _filename(UploadState state) {
    final path = state.primaryMedia?.file.path.trim() ?? '';
    if (path.isEmpty) return '';
    final normalized = path.replaceAll('\\', '/');
    return normalized.split('/').last;
  }

  static String _titleFor(UploadState state) {
    switch (state.status) {
      case UploadStatus.initializing:
        return 'Preparing upload…';
      case UploadStatus.uploading:
        return 'Uploading… ${(state.progress * 100).clamp(0, 100).round()}%';
      case UploadStatus.confirming:
        return 'Completing upload…';
      case UploadStatus.publishing:
      case UploadStatus.processing:
        return 'Uploaded. Finishing your Short…';
      case UploadStatus.ready:
        return 'Uploaded. Your Short is being reviewed.';
      case UploadStatus.failed:
        return state.errorMessage ?? 'Your Short could not be posted.';
      case UploadStatus.idle:
      case UploadStatus.picked:
        return 'Short selected';
    }
  }
}

class _StatusDisc extends StatelessWidget {
  const _StatusDisc({
    required this.progress,
    required this.isDone,
    required this.isFailed,
  });

  final double? progress;
  final bool isDone;
  final bool isFailed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (isDone) {
      return SizedBox.square(
        dimension: 48,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.primary.withValues(alpha: .10),
          ),
          child: Icon(
            Icons.check_circle_outline_rounded,
            color: scheme.primary,
          ),
        ),
      );
    }
    if (isFailed) {
      return SizedBox.square(
        dimension: 48,
        child: Icon(Icons.error_outline_rounded, color: scheme.error, size: 34),
      );
    }
    final value = progress;
    return SizedBox.square(
      dimension: 48,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CircularProgressIndicator(value: value, strokeWidth: 3),
          if (value != null)
            Text(
              '${(value * 100).clamp(0, 100).round()}%',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
            )
          else
            const Icon(Icons.upload_rounded, size: 20),
        ],
      ),
    );
  }
}
