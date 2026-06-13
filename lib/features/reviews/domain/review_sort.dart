enum ReviewSort {
  newest(apiValue: 'newest', chipLabel: 'Newest', sheetLabel: 'Newest First'),
  helpful(
    apiValue: 'helpful',
    chipLabel: 'Helpful',
    sheetLabel: 'Most Helpful',
  ),
  ratingHigh(
    apiValue: 'rating_high',
    chipLabel: 'Highest',
    sheetLabel: 'Rating: High to Low',
  ),
  ratingLow(
    apiValue: 'rating_low',
    chipLabel: 'Lowest',
    sheetLabel: 'Rating: Low to High',
  );

  const ReviewSort({
    required this.apiValue,
    required this.chipLabel,
    required this.sheetLabel,
  });

  final String apiValue;
  final String chipLabel;
  final String sheetLabel;
}
