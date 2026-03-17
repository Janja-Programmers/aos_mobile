import 'package:flutter/material.dart';

class AdListingTabs extends StatelessWidget {
  const AdListingTabs({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onChanged,
    this.counts,
  });

  final List<String> tabs;
  final String selected;

  final void Function(String status) onChanged;

  /// Optional: counts per tab, e.g. {'Active': 3, 'Reviewing': 2}
  final Map<String, int>? counts;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          final s = tabs[i];
          final active = s == selected;
          final c = counts?[s] ?? 0;

          return ChoiceChip(
            selected: active,
            onSelected: (_) => onChanged(s),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? Theme.of(
                            context,
                          ).colorScheme.onPrimary.withOpacity(0.20)
                        : Theme.of(context).dividerColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$c',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: active
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemCount: tabs.length,
      ),
    );
  }
}
