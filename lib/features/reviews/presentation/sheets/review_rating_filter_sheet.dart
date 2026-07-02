import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

Future<int?> showReviewRatingFilterSheet(
  BuildContext context, {
  int? selectedRating,
}) {
  return showModalBottomSheet<int>(
    context: context,
    builder: (sheetContext) {
      return _ReviewRatingFilterSheet(selectedRating: selectedRating);
    },
  );
}

class _ReviewRatingFilterSheet extends StatelessWidget {
  const _ReviewRatingFilterSheet({required this.selectedRating});

  final int? selectedRating;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const SizedBox(width: 48),
                Expanded(
                  child: Text(
                    'Filter',
                    textAlign: TextAlign.center,
                    style: context.h5,
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(5, (index) {
                  final rating = 5 - index;

                  return _RatingFilterOption(
                    rating: rating,
                    selected: selectedRating == rating,
                    onTap: () => Navigator.pop(context, rating),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingFilterOption extends StatelessWidget {
  const _RatingFilterOption({
    required this.rating,
    required this.selected,
    required this.onTap,
  });

  final int rating;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: selected
          ? colors.primaryRedSoft.withValues(alpha: 0.12)
          : colors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? colors.primary : colors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  size: 16,
                  color: colors.amber,
                );
              }),
              const SizedBox(width: 6),
              Text('$rating Star', style: context.p),
            ],
          ),
        ),
      ),
    );
  }
}
