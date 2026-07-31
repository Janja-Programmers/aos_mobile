import 'package:africaonlinestores/features/ads/domain/ad_draft.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';
import 'package:africaonlinestores/features/ads/shared/utils/pricing_rules.dart';
import 'package:africaonlinestores/shared/enums/ads.dart';

class AdFormPayloadBuilder {
  static Map<String, dynamic> build({
    required AdDraft d,
    required AdCategorySchema schema,
  }) {
    final payload = <String, dynamic>{
      'title': d.title.trim(),
      'location': d.locationId,
      'category': d.categoryId,
      'description': d.description.trim(),
      'images': d.images
          .asMap()
          .entries
          .map(
            (e) => {
              'media': e.value.fileId,
              'media_id': e.value.fileId,
              'image': e.value.url,
              'is_primary': e.value.isPrimary ? 1 : 0,
              'sort_order': e.key,
            },
          )
          .toList(),
    };

    if (!isEmptyStr(d.videoFileId)) {
      payload['video_media'] = d.videoFileId;
      payload['video_media_id'] = d.videoFileId;
    } else if (!isEmptyStr(d.videoUrl)) {
      payload['video'] = d.videoUrl;
    }

    final schemaByKey = {for (final a in schema.attributes) a.key: a};
    final details = <Map<String, dynamic>>[];

    for (final e in d.attributes.entries) {
      final key = e.key;
      final v = e.value;
      final a = schemaByKey[key];
      if (a == null) continue;

      final row = <String, dynamic>{'attribute': key};

      switch (a.type) {
        case AdAttributeType.number:
        case AdAttributeType.year:
          row['value_number'] = v;
          break;
        case AdAttributeType.boolean:
          row['value_bool'] = v == true ? 1 : 0;
          break;
        case AdAttributeType.multiselect:
          row['value_json'] = v;
          break;
        case AdAttributeType.date:
          row['value_date'] = v;
          break;
        case AdAttributeType.select:
        case AdAttributeType.text:
        case AdAttributeType.unknown:
          row['value_text'] = v;
          break;
      }

      details.add(row);
    }

    payload['details'] = details;

    final p = schema.pricing;
    final priceType = d.priceType;

    if (p.requirement != PricingRequirement.hidden) {
      final optionalEmpty =
          p.requirement == PricingRequirement.optional && isEmptyStr(priceType);

      if (!optionalEmpty) {
        if (!isEmptyStr(priceType)) payload['price_type'] = priceType;

        if (typeNeedsAmount(priceType)) {
          if (d.price != null) payload['price'] = d.price;

          if (typeNeedsUnit(priceType, p) && !isEmptyStr(d.priceUnit)) {
            payload['price_unit'] = d.priceUnit;
          }
        }

        final canSendOffer =
            priceType == 'Fixed' &&
            d.offerPrice != null &&
            d.offerPrice! > 0 &&
            d.price != null &&
            d.offerPrice! < d.price!;

        if (canSendOffer) {
          payload['offer_price'] = d.offerPrice;

          if (d.scheduleOfferDates ?? false) {
            if (d.offerStart != null) {
              payload['offer_start_date'] = _formatDate(d.offerStart!);
            }

            if (d.offerEnd != null) {
              payload['offer_end_date'] = _formatDate(d.offerEnd!);
            }
          }
        }
      }
    }

    return payload;
  }

  static String _formatDate(DateTime d) {
    return "${d.year.toString().padLeft(4, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.day.toString().padLeft(2, '0')}";
  }
}
