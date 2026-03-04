import 'dart:convert';

import 'package:africaonlinestores/shared/utils/enums.dart';

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

    // ----- META -----
    this.freeConsultation,
    this.requiresDeposit,
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

  // ----- META -----
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

    bool? freeConsultation,
    bool? requiresDeposit,
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

      attributes: attributes ?? this.attributes,

      description: description ?? this.description,

      priceType: priceType ?? this.priceType,
      currency: currency ?? this.currency,
      price: price ?? this.price,
      priceUnit: priceUnit ?? this.priceUnit,

      offerPrice: clearOffer ? null : (offerPrice ?? this.offerPrice),
      offerStart: clearOffer ? null : (offerStart ?? this.offerStart),
      offerEnd: clearOffer ? null : (offerEnd ?? this.offerEnd),

      freeConsultation: freeConsultation ?? this.freeConsultation,
      requiresDeposit: requiresDeposit ?? this.requiresDeposit,
    );
  }

  factory AdDraft.fromAd(Map<String, dynamic> json) {
    final item = json['item'] as Map<String, dynamic>;

    // -------- images ----------
    final images = (item['images'] as List? ?? [])
        .map(
          (e) => AdMediaImage(
            url: e['image'] ?? '',
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
      source: DraftSource.existingAd,
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
      priceUnit: item['price_unit'],

      // Offer
      offerPrice: null,
      offerStart: null,
      offerEnd: null,
    );
  }

  factory AdDraft.fromDraft(Map<String, dynamic> json) {
    final payload = json['payload_json'];

    Map<String, dynamic> data = {};

    if (payload != null && payload is String && payload.isNotEmpty) {
      data = jsonDecode(payload);
    }

    // -------- images ----------
    final images = (data['images'] as List? ?? [])
        .map(
          (e) => AdMediaImage(
            url: e['image'] ?? '',
            isPrimary: (e['is_primary'] ?? 0) == 1,
          ),
        )
        .toList();

    // -------- attributes ----------
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

    return AdDraft(
      source: DraftSource.adDraft,
      draftId: json['id'],

      // BASIC
      title: data['title'] ?? '',
      countryId: data['country'],
      locationId: data['location'],
      locationLabel: data['location'],
      categoryId: data['category'],
      categoryLabel: data['category'],

      // MEDIA
      images: images,
      videoUrl: data['video'],

      // DETAILS
      attributes: attrs,

      // DESCRIPTION
      description: data['description'] ?? '',

      // PRICING
      priceType: data['price_type'],
      currency: data['currency'],
      price: (data['price'] as num?)?.toDouble(),
      priceUnit: data['price_unit'],
    );
  }
}
