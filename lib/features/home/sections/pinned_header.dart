import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';

/// A small helper to create a pinned sliver header.
///
/// Used on Home (Ads list) so the search bar stays visible while the feed
/// scrolls, without introducing nested scroll views.
class PinnedHeaderSliver extends StatelessWidget {
  const PinnedHeaderSliver({
    super.key,
    required this.child,
    this.height = 60,
    this.padding = const EdgeInsets.fromLTRB(16, 10, 16, 8),
  });

  final Widget child;
  final double height;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _PinnedHeaderDelegate(
        minHeight: height,
        maxHeight: height,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: overlapsContent ? colors.border : Colors.transparent,
          ),
        ),
      ),
      child: SafeArea(bottom: false, child: child),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return minHeight != oldDelegate.minHeight ||
        maxHeight != oldDelegate.maxHeight ||
        child != oldDelegate.child;
  }
}
