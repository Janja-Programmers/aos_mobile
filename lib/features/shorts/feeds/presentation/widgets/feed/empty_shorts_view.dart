import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/shorts/feeds/application/state/shorts_feed_type.dart';

class EmptyShortsView extends StatelessWidget {
  final ShortsFeedType feedType;
  final String? categoryLabel;
  final Future<void> Function() onRefresh;

  const EmptyShortsView({
    super.key,
    required this.feedType,
    required this.onRefresh,
    this.categoryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final title = _title;
    final message = _message;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 130),

          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary.withOpacity(.08),
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

          const SizedBox(height: 18),

          Center(
            child: OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Refresh'),
            ),
          ),
        ],
      ),
    );
  }

  IconData get _icon {
    switch (feedType) {
      case ShortsFeedType.forYou:
        return Icons.play_circle_outline_rounded;
      case ShortsFeedType.following:
        return Icons.people_outline_rounded;
      case ShortsFeedType.live:
        return Icons.sensors_rounded;
    }
  }

  String get _title {
    final category = categoryLabel?.trim();

    if (category != null && category.isNotEmpty && category != 'All') {
      return 'No $category shorts yet';
    }

    switch (feedType) {
      case ShortsFeedType.forYou:
        return 'No shorts yet';
      case ShortsFeedType.following:
        return 'No following shorts yet';
      case ShortsFeedType.live:
        return 'No live shorts yet';
    }
  }

  String get _message {
    final category = categoryLabel?.trim();

    if (category != null && category.isNotEmpty && category != 'All') {
      return 'There are no shorts in this category right now. Pull down or tap refresh to check again.';
    }

    switch (feedType) {
      case ShortsFeedType.forYou:
        return 'Fresh shorts will appear here when creators start posting.';
      case ShortsFeedType.following:
        return 'Follow creators and shops to see their latest shorts here.';
      case ShortsFeedType.live:
        return 'Live content will appear here when sellers and creators go live.';
    }
  }
}
