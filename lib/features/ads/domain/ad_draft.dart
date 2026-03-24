import 'package:africaonlinestores/shared/enums/ads.dart';

class AdMediaImage {
  AdMediaImage({
    required this.url,
    required this.fileId,
    this.isPrimary = false,
    this.sortOrder,
  });

  final String url;
  final String fileId;
  final bool isPrimary;
  final int? sortOrder;

  factory AdMediaImage.fromUpload(Map<String, String> media) {
    return AdMediaImage(
      url: media['url'] ?? '',
      fileId: media['fileId'] ?? '',
      isPrimary: false,
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      "image": url,
      "name": fileId,
      "is_primary": isPrimary ? 1 : 0,
      "sort_order": sortOrder,
    };
  }

  AdMediaImage copyWith({
    String? url,
    String? fileId,
    bool? isPrimary,
    int? sortOrder,
  }) {
    return AdMediaImage(
      url: url ?? this.url,
      fileId: fileId ?? this.fileId,
      isPrimary: isPrimary ?? this.isPrimary,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class AdDraft {
  const AdDraft({
    required this.source,
    this.draftId,
    this.adId,

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
    this.videoFileId,

    // ---------- DETAILS ----------
    this.attributes = const <String, dynamic>{},

    // ---------- DESCRIPTION ----------
    this.description = '',

    // ---------- PRICING ----------
    this.priceType,
    this.price,
    this.priceUnit,

    // ---------- OFFER ----------
    this.offerPrice,
    this.offerStart,
    this.offerEnd,

    // ----- META -----
    this.freeConsultation,
    this.requiresDeposit,
    this.scheduleOfferDates,
  });

  final DraftSource source;
  final String? draftId;
  final String? adId;

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
  final String? videoFileId;

  // ---------- DETAILS ----------
  final Map<String, dynamic> attributes;

  // ---------- DESCRIPTION ----------
  final String description;

  final String? priceType;
  final double? price;
  final String? priceUnit;

  final double? offerPrice;
  final DateTime? offerStart;
  final DateTime? offerEnd;
  final bool? scheduleOfferDates;

  final bool? freeConsultation;
  final bool? requiresDeposit;

  // ------------------------------------------------------------------
  // COPY WITH
  // ------------------------------------------------------------------

  AdDraft copyWith({
    DraftSource? source,
    String? draftId,
    String? adId,
    String? title,

    String? countryId,
    String? locationId,
    String? locationLabel,
    String? categoryId,
    String? categoryLabel,

    List<AdMediaImage>? images,
    String? videoUrl,
    String? videoFileId,
    Map<String, dynamic>? attributes,

    String? description,

    String? priceType,
    double? price,
    String? priceUnit,

    double? offerPrice,
    DateTime? offerStart,
    DateTime? offerEnd,

    bool clearOfferPrice = false,
    bool clearOfferStart = false,
    bool clearOfferEnd = false,
    bool clearAllOffer = false,

    bool? freeConsultation,
    bool? requiresDeposit,
    bool? scheduleOfferDates,
  }) {
    return AdDraft(
      source: source ?? this.source,
      draftId: draftId ?? this.draftId,
      adId: adId ?? this.adId,

      title: title ?? this.title,

      countryId: countryId ?? this.countryId,
      locationId: locationId ?? this.locationId,
      locationLabel: locationLabel ?? this.locationLabel,
      categoryId: categoryId ?? this.categoryId,
      categoryLabel: categoryLabel ?? this.categoryLabel,

      images: images ?? this.images,
      videoUrl: videoUrl ?? this.videoUrl,
      videoFileId: videoFileId ?? this.videoFileId,

      attributes: attributes ?? this.attributes,

      description: description ?? this.description,

      priceType: priceType ?? this.priceType,
      price: price ?? this.price,
      priceUnit: priceUnit ?? this.priceUnit,

      offerPrice: (clearAllOffer || clearOfferPrice)
          ? null
          : (offerPrice ?? this.offerPrice),
      offerStart: (clearAllOffer || clearOfferStart)
          ? null
          : (offerStart ?? this.offerStart),
      offerEnd: (clearAllOffer || clearOfferEnd)
          ? null
          : (offerEnd ?? this.offerEnd),

      freeConsultation: freeConsultation ?? this.freeConsultation,
      requiresDeposit: requiresDeposit ?? this.requiresDeposit,
      scheduleOfferDates: scheduleOfferDates ?? this.scheduleOfferDates,
    );
  }

  factory AdDraft.fromAd(Map<String, dynamic> json) {
    final item = json;

    // -------- images ----------
    final images = (item['images'] as List? ?? [])
        .map(
          (e) => AdMediaImage(
            url: e['image'] ?? '',
            fileId: e['name'] ?? '',
            isPrimary: (e['is_primary'] ?? 0) == 1,
            sortOrder: e['sort_order'],
          ),
        )
        .toList();

    // -------- attributes ----------
    final attrs = <String, dynamic>{};

    final details = item['details'] as List? ?? [];

    for (final d in details) {
      final attr = d['attribute'];

      final dynamic value =
          d['value_text'] ??
          d['value_number'] ??
          d['value_bool'] ??
          d['value_date'] ??
          d['value_json'];

      if (attr != null && value != null) {
        attrs[attr] = value;
      }
    }

    return AdDraft(
      source: DraftSource.edit,
      adId: item['id'],

      // BASIC
      title: item['title'] ?? '',
      countryId: item['country'],
      locationId: item['location'],
      locationLabel: item['location'],
      categoryId: item['category'],
      categoryLabel: item['category'],

      // MEDIA
      images: images,
      videoUrl: item['video'],

      // DETAILS
      attributes: attrs,

      // DESCRIPTION
      description: item['description'] ?? '',

      // PRICING
      priceType: item['price_type'],
      price: (item['price'] as num?)?.toDouble(),
      priceUnit: item['price_unit'],

      // OFFER
      offerPrice: (item['offer_price'] as num?)?.toDouble(),
      offerStart: item['offer_start'] != null
          ? DateTime.tryParse(item['offer_start'])
          : null,
      offerEnd: item['offer_end'] != null
          ? DateTime.tryParse(item['offer_end'])
          : null,

      scheduleOfferDates:
          item['offer_start'] != null || item['offer_end'] != null,
    );
  }

  factory AdDraft.fromDraft(Map<String, dynamic> json) {
    final data = (json['item'] ?? {}) as Map<String, dynamic>;
    // -------------------------------
    // BASIC (fallback to hint fields)
    // -------------------------------
    final title = data['title'] ?? '';
    final category = data['category'];
    final location = data['location'];
    final country = data['country'];

    // -------------------------------
    // MEDIA
    // -------------------------------
    final images = (data['images'] as List? ?? [])
        .map(
          (e) => AdMediaImage(
            url: e['image'] ?? '',
            fileId: e['name'] ?? '',
            isPrimary: (e['is_primary'] ?? 0) == 1,
          ),
        )
        .toList();

    // -------------------------------
    // ATTRIBUTES
    // -------------------------------
    final attrs = <String, dynamic>{};

    final details = data['details'] as List? ?? [];

    for (final d in details) {
      final attr = d['attribute'];

      final dynamic value =
          d['value_text'] ??
          d['value_number'] ??
          d['value_bool'] ??
          d['value_date'] ??
          d['value_json'];

      if (attr != null && value != null) {
        attrs[attr] = value;
      }
    }

    // -------------------------------
    // DESCRIPTION
    // -------------------------------
    final description = data['description'] ?? '';

    // -------------------------------
    // PRICING
    // -------------------------------
    final priceType = data['price_type'];
    final price = (data['price'] as num?)?.toDouble();
    final priceUnit = data['price_unit'];

    final offerPrice = (data['offer_price'] as num?)?.toDouble();
    final offerStart = data['offer_start'] != null
        ? DateTime.tryParse(data['offer_start'])
        : null;

    final offerEnd = data['offer_end'] != null
        ? DateTime.tryParse(data['offer_end'])
        : null;

    final scheduleOfferDates =
        data['schedule_offer_dates'] ??
        (data['offer_start'] != null || data['offer_end'] != null);

    // -------------------------------
    // FINAL MODEL
    // -------------------------------
    final draft = AdDraft(
      source: DraftSource.draft,
      draftId: json['id'],

      // BASIC
      title: title,
      countryId: country,
      locationId: location,
      locationLabel: location,
      categoryId: category,
      categoryLabel: category,

      // MEDIA
      images: images,
      videoUrl: data['video'],

      // DETAILS
      attributes: attrs,

      // DESCRIPTION
      description: description,

      // PRICING
      priceType: priceType,
      price: price,
      priceUnit: priceUnit,

      offerPrice: offerPrice,
      offerStart: offerStart,
      offerEnd: offerEnd,
      scheduleOfferDates: scheduleOfferDates,
    );

    return draft;
  }
}
