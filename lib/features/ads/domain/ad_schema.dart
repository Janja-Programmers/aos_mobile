import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/ads/domain/ad_attribute.dart';
import 'package:africaonlinestores/features/ads/domain/category.dart';
import 'package:africaonlinestores/features/ads/domain/pricing_schema.dart';

class AdCategorySchema {
  const AdCategorySchema({
    required this.category,
    required this.attributes,
    required this.pricing,
  });

  final AdCategory category;
  final List<AdAttribute> attributes;
  final PricingSchema pricing;
}

class AdCategorySchemaModel extends AdCategorySchema {
  const AdCategorySchemaModel({
    required super.category,
    required super.attributes,
    required super.pricing,
  });

  factory AdCategorySchemaModel.fromPayload(Map<String, dynamic> payload) {
    final data = asJsonMap(payload['data']);

    /// CATEGORY
    final categoryMap = asJsonMap(data['category']);

    final category = AdCategoryModel.fromMap(categoryMap);

    /// ATTRIBUTES
    final attrs = <AdAttribute>[];

    for (final item in asJsonMapList(data['attributes'])) {
      attrs.add(AdAttributeModel.fromMap(item));
    }

    /// PRICING
    final pricingMap = asJsonMap(data['pricing']);

    final pricing = PricingSchemaModel.fromMap(pricingMap);

    return AdCategorySchemaModel(
      category: category,
      attributes: attrs,
      pricing: pricing,
    );
  }
}
