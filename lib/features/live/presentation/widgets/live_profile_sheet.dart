import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/live/application/providers/live_profile_provider.dart';
import 'package:africaonlinestores/features/live/domain/live_profile_summary.dart';
import 'package:africaonlinestores/features/live/presentation/live_l10n.dart';
import 'package:africaonlinestores/features/social/application/providers/social_providers.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/components/app_circle_avatar.dart';
import 'package:africaonlinestores/shared/components/verified_badge.dart';
import 'package:africaonlinestores/shared/utils/helpers.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveProfileSheetResult {
  const LiveProfileSheetResult({
    required this.accountId,
    required this.displayName,
    required this.avatarUrl,
  });

  final String accountId;
  final String displayName;
  final String? avatarUrl;
}

Future<LiveProfileSheetResult?> showLiveProfileSheet(
  BuildContext context, {
  required String accountId,
}) {
  return showModalBottomSheet<LiveProfileSheetResult>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LiveProfileSheet(accountId: accountId),
  );
}

class _LiveProfileSheet extends ConsumerStatefulWidget {
  const _LiveProfileSheet({required this.accountId});

  final String accountId;

  @override
  ConsumerState<_LiveProfileSheet> createState() => _LiveProfileSheetState();
}

class _LiveProfileSheetState extends ConsumerState<_LiveProfileSheet> {
  bool _relationshipInFlight = false;

  Future<void> _toggleRelationship(LiveProfileSummary profile) async {
    if (_relationshipInFlight || profile.isSelf || profile.isBlocked) return;
    setState(() => _relationshipInFlight = true);
    try {
      final result = await ref
          .read(socialRepositoryProvider)
          .toggleFollow(targetUser: profile.accountId);
      if (!mounted) return;
      if (result.isLeft) {
        ShowSnack(
          context,
          result.leftOrNull?.message ?? context.l10n.liveProfileActionFailed,
        ).error();
        return;
      }
      ref.invalidate(liveProfileSummaryProvider(profile.accountId));
    } on Object {
      if (mounted) {
        ShowSnack(context, context.l10n.liveProfileActionFailed).error();
      }
    } finally {
      if (mounted) setState(() => _relationshipInFlight = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final profileAsync = ref.watch(
      liveProfileSummaryProvider(widget.accountId),
    );

    return FractionallySizedBox(
      heightFactor: .86,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: colors.border),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 12, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.liveProfileLabel,
                            style: AppTextStylesX(context).caption.copyWith(
                              color: colors.textMuted,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            context.l10n.liveViewerProfileTitle,
                            style: context.h5,
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
              Expanded(
                child: profileAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => _ProfileError(
                    onRetry: () => ref.invalidate(
                      liveProfileSummaryProvider(widget.accountId),
                    ),
                  ),
                  data: (profile) => SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      children: [
                        AppCircularAvatar(
                          name: profile.displayName,
                          imageUrl: profile.avatarUrl,
                          radius: 58,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                profile.displayName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: context.h4,
                              ),
                            ),
                            if (profile.isVerified) ...[
                              const SizedBox(width: 6),
                              const VerifiedBadge(size: 20),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.accountId,
                          style: context.p.copyWith(color: colors.textMuted),
                        ),
                        const SizedBox(height: 20),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.elevated,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: colors.border),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _Stat(
                                    value: humanizeCount(
                                      profile.followersCount,
                                    ),
                                    label: context.l10n.liveFollowers,
                                  ),
                                ),
                                VerticalDivider(color: colors.border),
                                Expanded(
                                  child: _Stat(
                                    value: humanizeCount(
                                      profile.followingCount,
                                    ),
                                    label: context.l10n.liveFollowing,
                                  ),
                                ),
                                VerticalDivider(color: colors.border),
                                Expanded(
                                  child: _Stat(
                                    value: humanizeCount(profile.friendsCount),
                                    label: context.l10n.liveFriends,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (profile.bio.trim().isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            profile.bio.trim(),
                            textAlign: TextAlign.center,
                            style: context.p.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonalIcon(
                            onPressed:
                                profile.isSelf ||
                                    profile.isBlocked ||
                                    _relationshipInFlight
                                ? null
                                : () => unawaited(_toggleRelationship(profile)),
                            icon: _relationshipInFlight
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.person_add_alt_1_rounded),
                            label: Text(_relationshipLabel(context, profile)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).pop(
                              LiveProfileSheetResult(
                                accountId: profile.accountId,
                                displayName: profile.displayName,
                                avatarUrl: profile.avatarUrl,
                              ),
                            ),
                            icon: const Icon(Icons.open_in_new_rounded),
                            label: Text(context.l10n.liveOpenFullProfile),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          context.l10n.liveProfileKeepsRoom,
                          textAlign: TextAlign.center,
                          style: AppTextStylesX(
                            context,
                          ).caption.copyWith(color: colors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _relationshipLabel(BuildContext context, LiveProfileSummary profile) {
    if (profile.isSelf) return context.l10n.liveYou;
    if (profile.isFriend) return context.l10n.liveFriends;
    if (profile.isFollowing) return context.l10n.liveFollowing;
    if (profile.isFollowedBy) return context.l10n.liveFollowBack;
    return context.l10n.liveFollow;
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off_outlined, size: 48),
          const SizedBox(height: 12),
          Text(context.l10n.liveProfileUnavailable, style: context.h6),
          const SizedBox(height: 6),
          Text(
            context.l10n.liveProfileUnavailableBody,
            textAlign: TextAlign.center,
            style: context.p,
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onRetry,
            child: Text(
              context.l10n.liveTryAgain,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: context.pStrong),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStylesX(context).caption,
          ),
        ],
      ),
    );
  }
}
