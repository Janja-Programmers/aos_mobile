import 'package:africaonlinestores/core/media/domain/media_upload_result.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/shared/enums/ads.dart';

double? _optionalPositiveMoney(Object? value) {
  final parsed = asNullableDouble(value);
  if (parsed == null || parsed <= 0) return null;
  return parsed;
}

Object? _adDetailValue(Map<String, dynamic> detail) {
  return detail['value_text'] ??
      detail['value_number'] ??
      detail['value_date'] ??
      detail['value_json'] ??
      detail['value_bool'];
}

DateTime? _parseAdDate(Map<String, dynamic> item, String canonicalKey) {
  final legacyKey = canonicalKey == 'offer_start_date'
      ? 'offer_start'
      : 'offer_end';
  final value = item[canonicalKey] ?? item[legacyKey];
  if (value == null) return null;
  return DateTime.tryParse(asString(value));
}

bool _hasAdDate(Map<String, dynamic> item, String canonicalKey) {
  final legacyKey = canonicalKey == 'offer_start_date'
      ? 'offer_start'
      : 'offer_end';
  return item[canonicalKey] != null || item[legacyKey] != null;
}

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
    this.status,

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
  final String? status;

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
    String? status,
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

    bool clearPriceType = false,
    bool clearPrice = false,
    bool clearPriceUnit = false,
    bool clearPricing = false,

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
      status: status ?? this.status,

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

      priceType: (clearPricing || clearPriceType)
          ? null
          : (priceType ?? this.priceType),
      price: (clearPricing || clearPrice) ? null : (price ?? this.price),
      priceUnit: (clearPricing || clearPriceUnit)
          ? null
          : (priceUnit ?? this.priceUnit),

      offerPrice: (clearPricing || clearAllOffer || clearOfferPrice)
          ? null
          : (offerPrice ?? this.offerPrice),
      offerStart: (clearPricing || clearAllOffer || clearOfferStart)
          ? null
          : (offerStart ?? this.offerStart),
      offerEnd: (clearPricing || clearAllOffer || clearOfferEnd)
          ? null
          : (offerEnd ?? this.offerEnd),

      freeConsultation: freeConsultation ?? this.freeConsultation,
      requiresDeposit: requiresDeposit ?? this.requiresDeposit,
      scheduleOfferDates: scheduleOfferDates ?? this.scheduleOfferDates,
    );
  }

  factory AdDraft.fromAd(Map<String, dynamic> json) {
    final item = json;

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

    final attrs = <String, dynamic>{};
    final details = asJsonMapList(item['details']);

    for (final detail in details) {
      final attr = asNullableString(detail['attribute']);
      final value = _adDetailValue(detail);

      if (attr != null && value != null) {
        attrs[attr] = value;
      }
    }

    final offerPrice = _optionalPositiveMoney(item['offer_price']);
    final offerStart = offerPrice == null
        ? null
        : _parseAdDate(item, 'offer_start_date');
    final offerEnd = offerPrice == null
        ? null
        : _parseAdDate(item, 'offer_end_date');

    return AdDraft(
      source: DraftSource.edit,
      adId: asNullableString(item['id']),
      status: asNullableString(item['status']),

      title: asString(item['title']),
      countryId: asNullableString(item['country']),
      locationId: asNullableString(item['location']),
      locationLabel: asNullableString(item['location']),
      categoryId: asNullableString(item['category']),
      categoryLabel: asNullableString(item['category']),

      images: images,
      videoUrl: asNullableString(item['video']),
      videoFileId: asNullableString(
        item['video_media'] ?? item['video_media_id'] ?? item['video_file_id'],
      ),

      attributes: attrs,
      description: asString(item['description']),

      priceType: asNullableString(item['price_type']),
      price: asNullableDouble(item['price']),
      priceUnit: asNullableString(item['price_unit']),

      offerPrice: offerPrice,
      offerStart: offerStart,
      offerEnd: offerEnd,
      scheduleOfferDates:
          offerPrice != null &&
          (_hasAdDate(item, 'offer_start_date') ||
              _hasAdDate(item, 'offer_end_date')),
    );
  }

  factory AdDraft.fromDraft(Map<String, dynamic> data) {
    final title = asString(data['title']);
    final category = asNullableString(data['category']);
    final location = asNullableString(data['location']);
    final country = asNullableString(data['country']);

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
            sortOrder: asNullableInt(e['sort_order']),
          ),
        )
        .toList(growable: false);

    final attrs = <String, dynamic>{};
    final details = asJsonMapList(data['details']);

    for (final detail in details) {
      final attr = asNullableString(detail['attribute']);
      final value = _adDetailValue(detail);

      if (attr != null && value != null) {
        attrs[attr] = value;
      }
    }

    final description = asString(data['description']);
    final priceType = asNullableString(data['price_type']);
    final price = asNullableDouble(data['price']);
    final priceUnit = asNullableString(data['price_unit']);

    final offerPrice = _optionalPositiveMoney(data['offer_price']);
    final offerStart = offerPrice == null
        ? null
        : _parseAdDate(data, 'offer_start_date');
    final offerEnd = offerPrice == null
        ? null
        : _parseAdDate(data, 'offer_end_date');

    final scheduleOfferDates =
        offerPrice != null &&
        asBool(
          data['schedule_offer_dates'] ??
              (_hasAdDate(data, 'offer_start_date') ||
                  _hasAdDate(data, 'offer_end_date')),
        );

    return AdDraft(
      source: DraftSource.draft,
      draftId: asNullableString(data['id']),
      status: asNullableString(data['status']),

      title: title,
      countryId: country,
      locationId: location,
      locationLabel: location,
      categoryId: category,
      categoryLabel: category,

      images: images,
      videoUrl: asNullableString(data['video']),
      videoFileId: asNullableString(
        data['video_media'] ?? data['video_media_id'] ?? data['video_file_id'],
      ),

      attributes: attrs,
      description: description,

      priceType: priceType,
      price: price,
      priceUnit: priceUnit,

      offerPrice: offerPrice,
      offerStart: offerStart,
      offerEnd: offerEnd,
      scheduleOfferDates: scheduleOfferDates,
    );
  }
}
