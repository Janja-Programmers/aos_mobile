import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/search/widgets/search_recent_tile.dart';
import 'package:flutter/material.dart';

class SearchRecentSection extends StatelessWidget {
  const SearchRecentSection({
    super.key,
    required this.recent,
    required this.onDeleteAll,
    required this.onRemoveOne,
    required this.onPick,
  });

  final List<String> recent;
  final VoidCallback onDeleteAll;
  final ValueChanged<String> onRemoveOne;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 6),
              child: Row(
                children: [
                  Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  const Spacer(),

                  if (recent.isNotEmpty)
                    TextButton(
                      onPressed: onDeleteAll,
                      style: TextButton.styleFrom(
                        foregroundColor: colors.error,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                ],
              ),
            ),

            const Divider(height: 1),

            /// EMPTY STATE
            if (recent.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No recent searches yet.',
                  style: TextStyle(color: colors.textMuted),
                ),
              )
            /// LIST
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: recent.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final term = recent[i];

                    return SearchRecentTile(
                      term: term,
                      onTap: () => onPick(term),
                      onRemove: () => onRemoveOne(term),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
