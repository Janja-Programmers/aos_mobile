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
            (entry) => <String, dynamic>{
              'media': entry.value.fileId,
              'is_primary': entry.value.isPrimary ? 1 : 0,
              'sort_order': entry.key,
            },
          )
          .toList(growable: false),
    };

    if (!isEmptyStr(d.videoFileId)) {
      payload['video_media'] = d.videoFileId;
    }

    final schemaByKey = {
      for (final attribute in schema.attributes) attribute.key: attribute,
    };
    final details = <Map<String, dynamic>>[];

    for (final entry in d.attributes.entries) {
      final attribute = schemaByKey[entry.key];
      if (attribute == null) continue;

      final value = entry.value;
      // The backend accepts the category attribute key and resolves it to the
      // canonical attribute ID during create/update normalization. Keeping the
      // key in saved draft payloads also lets the form restore values before
      // submission without depending on display labels.
      final row = <String, dynamic>{'attribute': entry.key};

      switch (attribute.type) {
        case AdAttributeType.number:
        case AdAttributeType.year:
          row['value_number'] = value;
          break;
        case AdAttributeType.boolean:
          row['value_bool'] = value == true ? 1 : 0;
          break;
        case AdAttributeType.multiselect:
          row['value_json'] = value;
          break;
        case AdAttributeType.date:
          row['value_date'] = value;
          break;
        case AdAttributeType.select:
        case AdAttributeType.text:
        case AdAttributeType.unknown:
          row['value_text'] = value;
          break;
      }

      details.add(row);
    }

    payload['details'] = details;

    final pricing = schema.pricing;
    final priceType = resolvedPriceType(d.priceType, pricing);

    if (pricing.requirement != PricingRequirement.hidden) {
      final optionalEmpty =
          pricing.requirement == PricingRequirement.optional &&
          isEmptyStr(priceType);

      if (!optionalEmpty) {
        if (!isEmptyStr(priceType)) payload['price_type'] = priceType;

        if (typeNeedsAmount(priceType)) {
          if (d.price != null) payload['price'] = d.price;

          if (typeNeedsUnit(priceType, pricing) && !isEmptyStr(d.priceUnit)) {
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
