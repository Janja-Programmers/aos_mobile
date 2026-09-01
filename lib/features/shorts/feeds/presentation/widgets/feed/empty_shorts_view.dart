import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/shorts_feed_type.dart';
import 'package:africaonlinestores/features/shorts/feeds/presentation/feed_l10n.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';

class EmptyShortsView extends StatelessWidget {
  final ShortsFeedType feedType;
  final String? categoryLabel;
  final bool hasCategoryFilter;
  final Future<void> Function() onRefresh;

  const EmptyShortsView({
    super.key,
    required this.feedType,
    required this.onRefresh,
    this.categoryLabel,
    this.hasCategoryFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final title = _title(context);
    final message = _message(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 96),
          Semantics(
            liveRegion: true,
            child: Column(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary.withValues(alpha: .08),
                  ),
                  child: Icon(_icon, size: 36, color: colors.primary),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: context.h5.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: context.pMuted.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(context.l10n.feedRefresh),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  IconData get _icon {
    return switch (feedType) {
      ShortsFeedType.forYou => Icons.play_circle_outline_rounded,
      ShortsFeedType.following => Icons.people_outline_rounded,
      ShortsFeedType.live => Icons.sensors_rounded,
    };
  }

  String _title(BuildContext context) {
    final category = categoryLabel?.trim() ?? '';
    if (hasCategoryFilter && category.isNotEmpty) {
      return context.l10n.feedNoCategoryShortsTitle(category);
    }

    return switch (feedType) {
      ShortsFeedType.forYou => context.l10n.feedNoShortsTitle,
      ShortsFeedType.following => context.l10n.feedNoFollowingShortsTitle,
      ShortsFeedType.live => context.l10n.feedNoLivesTitle,
    };
  }

  String _message(BuildContext context) {
    if (hasCategoryFilter) {
      return context.l10n.feedNoCategoryShortsMessage;
    }

    return switch (feedType) {
      ShortsFeedType.forYou => context.l10n.feedNoShortsMessage,
      ShortsFeedType.following => context.l10n.feedNoFollowingShortsMessage,
      ShortsFeedType.live => context.l10n.feedNoLivesMessage,
    };
  }
}
