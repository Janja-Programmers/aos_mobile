enum DealType { all, deals, offers, flashSale, newProducts }

extension DealTypeX on DealType {
  /// Value sent to API
  String? get apiValue {
    switch (this) {
      case DealType.all:
        return null;
      case DealType.deals:
        return 'deal';
      case DealType.offers:
        return 'offer';
      case DealType.flashSale:
        return 'flash_sale';
      case DealType.newProducts:
        return null;
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
      case 'deal':
        return DealType.deals;
      case 'offer':
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
