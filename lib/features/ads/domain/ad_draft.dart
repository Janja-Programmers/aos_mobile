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
    // ---------- BASIC ----------
    this.title = '',
    this.countryId,
    this.locationId,
    this.locationLabel,
    this.categoryId,
    this.categoryLabel,

    // ---------- MEDIA ----------
    this.images = const <AdMediaImage>[],
    this.videoUrl,

    // ---------- DETAILS ----------
    this.attributes = const <String, dynamic>{},

    // ---------- DESCRIPTION ----------
    this.description = '',

    // ---------- PRICING ----------
    this.priceType,
    this.currency,
    this.price,
    this.priceUnit,

    // ---------- OFFER ----------
    this.offerPrice,
    this.offerStart,
    this.offerEnd,
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
  final Map<String, dynamic> attributes;

  // ---------- DESCRIPTION ----------
  final String description;

  // ---------- PRICING ----------
  final String? priceType; // backend: price_type
  final String? currency; // backend: currency
  final double? price; // backend: price
  final String? priceUnit; // backend: price_unit

  // ---------- OFFER ----------
  final double? offerPrice; // backend: offer_price
  final DateTime? offerStart; // backend: offer_start
  final DateTime? offerEnd; // backend: offer_end

  // ------------------------------------------------------------------
  // COPY WITH
  // ------------------------------------------------------------------

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
    double? offerPrice,
    DateTime? offerStart,
    DateTime? offerEnd,
    bool clearOffer = false,
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

      // Offer logic
      offerPrice: clearOffer ? null : (offerPrice ?? this.offerPrice),
      offerStart: clearOffer ? null : (offerStart ?? this.offerStart),
      offerEnd: clearOffer ? null : (offerEnd ?? this.offerEnd),
    );
  }
}
