import 'package:africaonlinestores/core/media/livekit_service.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/live/presentation/live_l10n.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/components/app_circle_avatar.dart';
import 'package:flutter/material.dart';

Future<String?> showLiveViewersSheet(
  BuildContext context, {
  required int viewerCount,
  required Stream<List<LiveKitAudienceParticipant>> participants,
}) {
  return showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) =>
        _LiveViewersSheet(viewerCount: viewerCount, participants: participants),
  );
}

class _LiveViewersSheet extends StatelessWidget {
  const _LiveViewersSheet({
    required this.viewerCount,
    required this.participants,
  });

  final int viewerCount;
  final Stream<List<LiveKitAudienceParticipant>> participants;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .55,
      minChildSize: .34,
      maxChildSize: .90,
      builder: (context, scrollController) {
        return Material(
          color: colors.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            side: BorderSide(color: colors.border),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 12, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.liveViewersTitle,
                            style: context.h5,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.l10n.liveWatchingNow(viewerCount),
                            style: AppTextStylesX(
                              context,
                            ).caption.copyWith(color: colors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: context.l10n.liveClose,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: colors.border),
              Expanded(
                child: StreamBuilder<List<LiveKitAudienceParticipant>>(
                  stream: participants,
                  builder: (context, snapshot) {
                    final items =
                        snapshot.data ?? const <LiveKitAudienceParticipant>[];
                    if (items.isEmpty) {
                      return SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(28),
                        child: Center(
                          child: Text(
                            context.l10n.liveNoViewers,
                            textAlign: TextAlign.center,
                            style: context.p.copyWith(color: colors.textMuted),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        indent: 72,
                        color: colors.border.withValues(alpha: .65),
                      ),
                      itemBuilder: (context, index) {
                        final participant = items[index];
                        return Semantics(
                          button: participant.canOpenProfile,
                          label: participant.canOpenProfile
                              ? '${participant.displayName}, ${context.l10n.liveViewProfile}'
                              : participant.displayName,
                          child: ListTile(
                            minTileHeight: 60,
                            enabled: participant.canOpenProfile,
                            onTap: participant.canOpenProfile
                                ? () => Navigator.of(
                                    context,
                                  ).pop(participant.accountId)
                                : null,
                            leading: AppCircularAvatar(
                              name: participant.displayName,
                              imageUrl: participant.avatar,
                              radius: 22,
                            ),
                            title: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    participant.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.pStrong,
                                  ),
                                ),
                                if (participant.isCohost) ...[
                                  const SizedBox(width: 8),
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: colors.elevated,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: colors.border),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      child: Text(
                                        context.l10n.liveCohostLabel,
                                        style: AppTextStylesX(context).caption,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Text(
                              participant.canOpenProfile
                                  ? context.l10n.liveViewProfile
                                  : context.l10n.liveGuestViewer,
                              style: AppTextStylesX(
                                context,
                              ).caption.copyWith(color: colors.textMuted),
                            ),
                            trailing: participant.canOpenProfile
                                ? const Icon(Icons.chevron_right_rounded)
                                : null,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
