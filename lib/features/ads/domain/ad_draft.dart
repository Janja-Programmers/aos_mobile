class AdMediaImage {
  AdMediaImage({required this.url, this.isPrimary = false, this.sortOrder});

  final String url;
  final bool isPrimary;
  final int? sortOrder;

  AdMediaImage copyWith({String? url, bool? isPrimary, int? sortOrder}) {
    return AdMediaImage(
      url: url ?? this.url,
      isPrimary: isPrimary ?? this.isPrimary,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class AdDraft {
  const AdDraft({
    this.title = '',
    this.countryId,
    this.locationId,
    this.locationLabel,
    this.categoryId,
    this.categoryLabel,

    this.images = const <AdMediaImage>[],
    this.videoUrl,

    /// UI-only, category-driven values
    this.attributes = const <String, dynamic>{},

    this.description = '',

    // --- Pricing (FIRST-CLASS, backend-aligned) ---
    this.priceType,
    this.currency,
    this.price,
    this.priceUnit,
  });

  // ---------- BASIC ----------
  final String title;

  final String? countryId;
  final String? locationId;
  final String? locationLabel;

  final String? categoryId;
  final String? categoryLabel;

  // ---------- MEDIA ----------
  final List<AdMediaImage> images;
  final String? videoUrl;

  // ---------- DETAILS ----------
  /// UI-friendly structure; mapped to Ad Attribute Value table on submit
  final Map<String, dynamic> attributes;

  // ---------- DESCRIPTION ----------
  final String description;

  // ---------- PRICING ----------
  final String? priceType; // price_type
  final String? currency; // currency
  final double? price; // price
  final String? priceUnit; // price_unit

  AdDraft copyWith({
    String? title,
    String? countryId,
    String? locationId,
    String? locationLabel,
    String? categoryId,
    String? categoryLabel,
    List<AdMediaImage>? images,
    String? videoUrl,
    Map<String, dynamic>? attributes,
    String? description,
    String? priceType,
    String? currency,
    double? price,
    String? priceUnit,
  }) {
    return AdDraft(
      title: title ?? this.title,
      countryId: countryId ?? this.countryId,
      locationId: locationId ?? this.locationId,
      locationLabel: locationLabel ?? this.locationLabel,
      categoryId: categoryId ?? this.categoryId,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      images: images ?? this.images,
      videoUrl: videoUrl ?? this.videoUrl,
      attributes: attributes ?? this.attributes,
      description: description ?? this.description,
      priceType: priceType ?? this.priceType,
      currency: currency ?? this.currency,
      price: price ?? this.price,
      priceUnit: priceUnit ?? this.priceUnit,
    );
  }
}
