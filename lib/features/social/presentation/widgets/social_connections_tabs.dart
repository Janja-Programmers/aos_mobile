import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/social/application/state/social_connections_state.dart';
import 'package:flutter/material.dart';

class SocialConnectionsTabs extends StatelessWidget {
  final SocialConnectionsTab selectedTab;
  final int followingCount;
  final int followersCount;
  final int friendsCount;
  final ValueChanged<SocialConnectionsTab> onChanged;

  const SocialConnectionsTabs({
    super.key,
    required this.selectedTab,
    required this.followingCount,
    required this.followersCount,
    required this.friendsCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _TabButton(
              label: 'Following',
              count: followingCount,
              selected: selectedTab == SocialConnectionsTab.following,
              onTap: () => onChanged(SocialConnectionsTab.following),
            ),
            _TabButton(
              label: 'Followers',
              count: followersCount,
              selected: selectedTab == SocialConnectionsTab.followers,
              onTap: () => onChanged(SocialConnectionsTab.followers),
            ),
            _TabButton(
              label: 'Friends',
              count: friendsCount,
              selected: selectedTab == SocialConnectionsTab.friends,
              onTap: () => onChanged(SocialConnectionsTab.friends),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? colors.textPrimary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          '$label ${_formatCount(count)}',
          style: context.p.copyWith(
            color: selected ? colors.textPrimary : colors.textMuted,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      final value = count / 1000000;
      return '${value.toStringAsFixed(value >= 10 ? 0 : 1)}M';
    }

    if (count >= 1000) {
      return count.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (match) => '${match[1]},',
      );
    }

    return count.toString();
  }
}
