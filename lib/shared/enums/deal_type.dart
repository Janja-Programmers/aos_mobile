enum DealType { all, deals, offers, flashSale, newProducts }

extension DealTypeX on DealType {
  /// Value sent to API
  String? get apiValue {
    switch (this) {
      case DealType.all:
        return null;
      case DealType.deals:
        return 'deals';
      case DealType.offers:
        return 'offers';
      case DealType.flashSale:
        return 'flash_sale';
      case DealType.newProducts:
        return 'new_products';
    }
  }

  /// Label used in UI
  String get label {
    switch (this) {
      case DealType.all:
        return 'All';
      case DealType.deals:
        return 'Deals';
      case DealType.offers:
        return 'Offers';
      case DealType.flashSale:
        return 'Flash Sale';
      case DealType.newProducts:
        return 'New Products';
    }
  }

  /// Parse from query parameter
  static DealType fromString(String? value) {
    switch (value) {
      case 'deals':
        return DealType.deals;
      case 'offers':
        return DealType.offers;
      case 'flash_sale':
        return DealType.flashSale;
      case 'new_products':
        return DealType.newProducts;
      default:
        return DealType.all;
    }
  }
}
