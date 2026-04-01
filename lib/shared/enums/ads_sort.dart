enum AdsSort { ratingHigh, priceLow, priceHigh, recent }

extension AdsSortX on AdsSort {
  String get apiValue {
    switch (this) {
      case AdsSort.ratingHigh:
        return 'rating_high';
      case AdsSort.priceLow:
        return 'price_low';
      case AdsSort.priceHigh:
        return 'price_high';
      case AdsSort.recent:
        return 'recent';
    }
  }

  String get label {
    switch (this) {
      case AdsSort.ratingHigh:
        return 'Top Rated';
      case AdsSort.priceLow:
        return 'Lowest Price';
      case AdsSort.priceHigh:
        return 'Highest Price';
      case AdsSort.recent:
        return 'Newest';
    }
  }
}
