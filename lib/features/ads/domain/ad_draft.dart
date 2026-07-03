import 'package:africaonlinestores/core/media/domain/media_upload_result.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
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

  factory AdMediaImage.fromUpload(MediaUploadResult media) {
    return AdMediaImage(url: media.url, fileId: media.mediaId);
  }

  Map<String, dynamic> toPayload() {
    return {
      'media': fileId,
      'media_id': fileId,
      'image': url,
      'is_primary': isPrimary ? 1 : 0,
      'sort_order': sortOrder,
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
    final images = asJsonMapList(item['images'])
        .map(
          (Map<String, dynamic> e) => AdMediaImage(
            url: asString(e['image'] ?? e['url']),
            fileId: asString(
              e['media_id'] ??
                  e['media'] ??
                  e['name'] ??
                  e['file_id'] ??
                  e['file'],
            ),
            isPrimary: asInt(e['is_primary']) == 1,
            sortOrder: asNullableInt(e['sort_order']),
          ),
        )
        .toList(growable: false);

    // -------- attributes ----------
    final attrs = <String, dynamic>{};

    final details = asJsonMapList(item['details']);

    for (final d in details) {
      final attr = asNullableString(d['attribute']);

      final Object? value =
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
      adId: asNullableString(item['id']),

      // BASIC
      title: asString(item['title']),
      countryId: asNullableString(item['country']),
      locationId: asNullableString(item['location']),
      locationLabel: asNullableString(item['location']),
      categoryId: asNullableString(item['category']),
      categoryLabel: asNullableString(item['category']),

      // MEDIA
      images: images,
      videoUrl: asNullableString(item['video']),
      videoFileId: asNullableString(
        item['video_media'] ?? item['video_media_id'] ?? item['video_file_id'],
      ),

      // DETAILS
      attributes: attrs,

      // DESCRIPTION
      description: asString(item['description']),

      // PRICING
      priceType: asNullableString(item['price_type']),
      price: asNullableDouble(item['price']),
      priceUnit: asNullableString(item['price_unit']),

      // OFFER
      offerPrice: asNullableDouble(item['offer_price']),
      offerStart: item['offer_start'] != null
          ? DateTime.tryParse(asString(item['offer_start']))
          : null,
      offerEnd: item['offer_end'] != null
          ? DateTime.tryParse(asString(item['offer_end']))
          : null,

      scheduleOfferDates:
          item['offer_start'] != null || item['offer_end'] != null,
    );
  }

  factory AdDraft.fromDraft(Map<String, dynamic> json) {
    final data = asJsonMap(json['item']);
    // -------------------------------
    // BASIC (fallback to hint fields)
    // -------------------------------
    final title = asString(data['title']);
    final category = asNullableString(data['category']);
    final location = asNullableString(data['location']);
    final country = asNullableString(data['country']);

    // -------------------------------
    // MEDIA
    // -------------------------------
    final images = asJsonMapList(data['images'])
        .map(
          (Map<String, dynamic> e) => AdMediaImage(
            url: asString(e['image'] ?? e['url']),
            fileId: asString(
              e['media_id'] ??
                  e['media'] ??
                  e['name'] ??
                  e['file_id'] ??
                  e['file'],
            ),
            isPrimary: asInt(e['is_primary']) == 1,
          ),
        )
        .toList(growable: false);

    // -------------------------------
    // ATTRIBUTES
    // -------------------------------
    final attrs = <String, dynamic>{};

    final details = asJsonMapList(data['details']);

    for (final d in details) {
      final attr = asNullableString(d['attribute']);

      final Object? value =
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
    final description = asString(data['description']);

    // -------------------------------
    // PRICING
    // -------------------------------
    final priceType = asNullableString(data['price_type']);
    final price = asNullableDouble(data['price']);
    final priceUnit = asNullableString(data['price_unit']);

    final offerPrice = asNullableDouble(data['offer_price']);
    final offerStart = data['offer_start'] != null
        ? DateTime.tryParse(asString(data['offer_start']))
        : null;

    final offerEnd = data['offer_end'] != null
        ? DateTime.tryParse(asString(data['offer_end']))
        : null;

    final scheduleOfferDates =
        data['schedule_offer_dates'] ??
        (data['offer_start'] != null || data['offer_end'] != null);

    // -------------------------------
    // FINAL MODEL
    // -------------------------------
    final draft = AdDraft(
      source: DraftSource.draft,
      draftId: asNullableString(json['id']),

      // BASIC
      title: title,
      countryId: country,
      locationId: location,
      locationLabel: location,
      categoryId: category,
      categoryLabel: category,

      // MEDIA
      images: images,
      videoUrl: asNullableString(data['video']),
      videoFileId: asNullableString(
        data['video_media'] ?? data['video_media_id'] ?? data['video_file_id'],
      ),

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
      scheduleOfferDates: asBool(scheduleOfferDates),
    );

    return draft;
  }
}
