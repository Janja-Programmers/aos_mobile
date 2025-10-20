import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'tile.dart';

class ShortcutItem {
  final String title;
  final String route;
  final int? count;
  final bool highlight;

  ShortcutItem({
    required this.title,
    required this.route,
    this.count,
    this.highlight = false,
  });
}

class DashboardShortcuts extends StatelessWidget {
  final List<ShortcutItem> items;
  final EdgeInsets padding;
  final String titleText;

  const DashboardShortcuts({
    super.key,
    required this.items,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.titleText = 'Your Shortcuts',
  });

  @override
  Widget build(BuildContext context) {
    // Use 2 columns for the grid
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleText,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3.0,
            ),
            itemBuilder: (context, i) {
              final it = items[i];
              return DashboardTile(
                title: it.title,
                count: it.count,
                highlight: it.highlight,
                onTap: () {
                  if (it.route.isNotEmpty) {
                    context.push(it.route);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
