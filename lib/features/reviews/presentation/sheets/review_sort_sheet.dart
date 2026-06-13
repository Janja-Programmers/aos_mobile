import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/reviews/domain/review_sort.dart';

Future<ReviewSort?> showReviewSortSheet(
  BuildContext context, {
  required ReviewSort selectedSort,
}) {
  return showModalBottomSheet<ReviewSort>(
    context: context,
    builder: (sheetContext) {
      return _ReviewSortSheet(selectedSort: selectedSort);
    },
  );
}

class _ReviewSortSheet extends StatelessWidget {
  const _ReviewSortSheet({required this.selectedSort});

  final ReviewSort selectedSort;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sort By', style: context.h5),
            const SizedBox(height: 12),
            ...ReviewSort.values.map((sort) {
              final selected = sort == selectedSort;

              return InkWell(
                onTap: () => Navigator.pop(context, sort),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? colors.primary : colors.textMuted,
                            width: selected ? 2 : 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: selected
                            ? Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Text(sort.sheetLabel, style: context.p)),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
