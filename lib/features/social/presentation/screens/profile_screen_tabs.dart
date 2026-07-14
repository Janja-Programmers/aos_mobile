part of 'profile_screen.dart';

class _ProfileTabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color backgroundColor;

  const _ProfileTabsHeaderDelegate({
    required this.child,
    required this.backgroundColor,
  });

  @override
  double get minExtent => 72;

  @override
  double get maxExtent => 72;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(color: backgroundColor, child: child);
  }

  @override
  bool shouldRebuild(covariant _ProfileTabsHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

class _ProfileTabs extends StatelessWidget {
  final _ProfilePanel selected;
  final ValueChanged<_ProfilePanel> onChanged;
  final bool isOwnProfile;

  const _ProfileTabs({
    required this.selected,
    required this.onChanged,
    required this.isOwnProfile,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              for (final panel in _ProfilePanel.values.where(
                (panel) =>
                    isOwnProfile ||
                    (panel != _ProfilePanel.privateShorts &&
                        panel != _ProfilePanel.saved &&
                        panel != _ProfilePanel.liked),
              ))
                Expanded(
                  child: _TabIcon(
                    icon: panel.icon,
                    label: panel.label,
                    isSelected: selected == panel,
                    color: selected == panel
                        ? colors.primary
                        : colors.textMuted,
                    onTap: () => onChanged(panel),
                  ),
                ),
            ],
          ),
        ),
        Container(height: 1, color: colors.border),
      ],
    );
  }
}

class _TabIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TabIcon({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 5),
          Text(
            label,
            style: context.p.copyWith(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: isSelected ? 34 : 0,
            height: 3,
            decoration: BoxDecoration(
              color: isSelected ? colors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}
