import 'package:flutter/material.dart';

import 'package:africaonlinestores/ui/components/app_text_styles.dart';
import 'package:africaonlinestores/features/ads/all_ads/all_ads_state.dart';

class ViewToggleBar extends StatelessWidget {
  const ViewToggleBar({
    super.key,
    required this.view,
    required this.onToggle,
    required this.onSort,
    required this.onFilter,
  });

  final ViewMode view;
  final VoidCallback onToggle;
  final VoidCallback onSort;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          /// Sort
          InkWell(
            onTap: onSort,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Text(
                    'Best Match',
                    style: context.pStrong.copyWith(color: scheme.primary),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.keyboard_arrow_down, color: scheme.primary),
                ],
              ),
            ),
          ),

          const Spacer(),

          /// View Toggle (Grid/List)
          IconButton(
            onPressed: onToggle,
            tooltip: view == ViewMode.grid
                ? 'Switch to List View'
                : 'Switch to Grid View',
            icon: Icon(
              view == ViewMode.grid
                  ? Icons.view_list_outlined
                  : Icons.grid_view_outlined,
            ),
          ),

          const SizedBox(width: 6),

          /// Filter
          Row(
            children: [
              Text('Filter', style: context.p),
              IconButton(
                onPressed: onFilter,
                icon: const Icon(Icons.filter_list),
                tooltip: 'Open Filters',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
