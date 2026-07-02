import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class NotificationTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const NotificationTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const tabs = ['All', 'Messages', 'Activity'];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = tab == selected;

          return GestureDetector(
            onTap: () => onChanged(tab),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? colors.primary : colors.border,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                tab,
                style: context.p.copyWith(
                  color: isSelected ? colors.surface : colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
