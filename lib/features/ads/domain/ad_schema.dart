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
    final data = payload['data'] ?? {};

    /// CATEGORY
    final categoryMap = Map<String, dynamic>.from(data['category'] ?? {});

    final category = AdCategoryModel.fromMap(categoryMap);

    /// ATTRIBUTES
    final attrs = <AdAttribute>[];

    if (data['attributes'] is List) {
      for (final item in data['attributes']) {
        final attrMap = Map<String, dynamic>.from(item);

        attrs.add(AdAttributeModel.fromMap(attrMap));
      }
    }

    /// PRICING
    final pricingMap = Map<String, dynamic>.from(data['pricing'] ?? {});

    final pricing = PricingSchemaModel.fromMap(pricingMap);

    return AdCategorySchemaModel(
      category: category,
      attributes: attrs,
      pricing: pricing,
    );
  }
}
