import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/shared/enums/ads_sort.dart';
import 'package:flutter/material.dart';

String adsSortLabel(AdsSort? sort) {
  switch (sort) {
    case null:
      return 'Best Match';
    case AdsSort.priceLow:
      return 'Price: Low to High';
    case AdsSort.priceHigh:
      return 'Price: High to Low';
    case AdsSort.recent:
      return 'Newest First';
    case AdsSort.ratingHigh:
      return 'Top Rated';
  }
}

void showAdsSortSheet(
  BuildContext context, {
  required AdsSort? selectedSort,
  required ValueChanged<AdsSort?> onChanged,
}) {
  final colors = context.appColors;

  unawaited(
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.elevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final options = <AdsSort?>[
          null,
          AdsSort.priceLow,
          AdsSort.priceHigh,
          AdsSort.recent,
          AdsSort.ratingHigh,
        ];

        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sort By', style: context.h4),
                const SizedBox(height: 20),
                ...options.map((option) {
                  final selected = option == selectedSort;
                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      onChanged(option);
                      Navigator.pop(sheetContext);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          Icon(
                            selected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: selected ? colors.primary : colors.textMuted,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              adsSortLabel(option),
                              style: context.p.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    ),
  );
}

void showAdsFilterSheet(
  BuildContext context, {
  required int? initialPriceMin,
  required int? initialPriceMax,
  required int? initialRatingMin,
  required bool initialVerifiedSellers,
  required bool showVerifiedSellerFilter,
  required void Function({
    int? priceMin,
    int? priceMax,
    int? ratingMin,
    bool verifiedSellers,
  })
  onApply,
}) {
  final colors = context.appColors;

  int? selectedMin = initialPriceMin;
  int? selectedMax = initialPriceMax;
  int? selectedRating = initialRatingMin;
  bool verified = initialVerifiedSellers;

  unawaited(
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.elevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Widget chip({
              required String label,
              required bool selected,
              required VoidCallback onTap,
            }) {
              return Semantics(
                button: true,
                selected: selected,
                child: GestureDetector(
                  onTap: onTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? colors.primary.withValues(alpha: 0.16)
                          : colors.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: selected ? colors.primary : colors.border,
                      ),
                    ),
                    child: Text(
                      label,
                      style: context.p.copyWith(
                        color: selected ? colors.primary : colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }

            bool priceSelected(int? min, int? max) {
              return selectedMin == min && selectedMax == max;
            }

            return SafeArea(
              top: false,
              child: FractionallySizedBox(
                heightFactor: 0.88,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    24,
                    20,
                    MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text('Filter', style: context.h4)),
                          TextButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            child: Text(
                              'Close',
                              style: context.p.copyWith(color: colors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text('Price Range', style: context.pStrong),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 12,
                        children: [
                          chip(
                            label: 'Under KSh 500',
                            selected: priceSelected(null, 500),
                            onTap: () => setSheetState(() {
                              if (priceSelected(null, 500)) {
                                selectedMin = null;
                                selectedMax = null;
                              } else {
                                selectedMin = null;
                                selectedMax = 500;
                              }
                            }),
                          ),
                          chip(
                            label: 'KSh 500 - KSh 1,000',
                            selected: priceSelected(500, 1000),
                            onTap: () => setSheetState(() {
                              if (priceSelected(500, 1000)) {
                                selectedMin = null;
                                selectedMax = null;
                              } else {
                                selectedMin = 500;
                                selectedMax = 1000;
                              }
                            }),
                          ),
                          chip(
                            label: 'KSh 1,000 - KSh 5,000',
                            selected: priceSelected(1000, 5000),
                            onTap: () => setSheetState(() {
                              if (priceSelected(1000, 5000)) {
                                selectedMin = null;
                                selectedMax = null;
                              } else {
                                selectedMin = 1000;
                                selectedMax = 5000;
                              }
                            }),
                          ),
                          chip(
                            label: 'Above KSh 5,000',
                            selected: priceSelected(5000, null),
                            onTap: () => setSheetState(() {
                              if (priceSelected(5000, null)) {
                                selectedMin = null;
                                selectedMax = null;
                              } else {
                                selectedMin = 5000;
                                selectedMax = null;
                              }
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text('Rating', style: context.pStrong),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 12,
                        children: [
                          for (final rating in const [4, 3, 2])
                            chip(
                              label: '$rating Stars & Above',
                              selected: selectedRating == rating,
                              onTap: () => setSheetState(() {
                                selectedRating = selectedRating == rating
                                    ? null
                                    : rating;
                              }),
                            ),
                        ],
                      ),
                      if (showVerifiedSellerFilter) ...[
                        const SizedBox(height: 22),
                        Text('Seller', style: context.pStrong),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 12,
                          children: [
                            chip(
                              label: 'Verified Sellers',
                              selected: verified,
                              onTap: () => setSheetState(() {
                                verified = !verified;
                              }),
                            ),
                            chip(
                              label: 'All Sellers',
                              selected: !verified,
                              onTap: () => setSheetState(() {
                                verified = false;
                              }),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 36),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: colors.primary,
                            foregroundColor: colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            onApply(
                              priceMin: selectedMin,
                              priceMax: selectedMax,
                              ratingMin: selectedRating,
                              verifiedSellers:
                                  showVerifiedSellerFilter && verified,
                            );
                            Navigator.pop(sheetContext);
                          },
                          child: Text('Apply Filter', style: context.pStrong),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
