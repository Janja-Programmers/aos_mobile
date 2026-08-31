import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/notifications/domain/notification_category.dart';
import 'package:flutter/material.dart';

class NotificationTabs extends StatelessWidget {
  const NotificationTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final NotificationCategory selected;
  final ValueChanged<NotificationCategory> onChanged;

  static const List<NotificationCategory> tabs = <NotificationCategory>[
    NotificationCategory.all,
    NotificationCategory.communication,
    NotificationCategory.activity,
    NotificationCategory.marketplace,
    NotificationCategory.account,
  ];

  static String label(NotificationCategory category) {
    return switch (category) {
      NotificationCategory.all => 'All',
      NotificationCategory.communication => 'Messages',
      NotificationCategory.activity => 'Activity',
      NotificationCategory.marketplace => 'Marketplace',
      NotificationCategory.account => 'Account',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final NotificationCategory tab = tabs[index];
          final bool isSelected = tab == selected;
          final String text = label(tab);
          return Semantics(
            button: true,
            selected: isSelected,
            label: text,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: isSelected ? null : () => onChanged(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : colors.border,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  text,
                  maxLines: 1,
                  style: context.p.copyWith(
                    color: isSelected ? colors.white : colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
