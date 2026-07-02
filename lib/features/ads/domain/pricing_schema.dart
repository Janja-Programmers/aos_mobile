import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/shared/enums/ads.dart';

class PricingSchema {
  const PricingSchema({
    required this.requirement,
    this.allowedTypes = const [],
    this.allowedUnits = const [],
  });

  final PricingRequirement requirement;
  final List<String> allowedTypes;
  final List<String> allowedUnits;
}

class PricingSchemaModel extends PricingSchema {
  const PricingSchemaModel({
    required super.requirement,
    super.allowedTypes,
    super.allowedUnits,
  });

  static PricingRequirement _parseRequirement(String raw) {
    final v = raw.trim().toLowerCase();
    switch (v) {
      case 'hidden':
        return PricingRequirement.hidden;
      case 'required':
        return PricingRequirement.required;
      default:
        return PricingRequirement.optional;
    }
  }

  factory PricingSchemaModel.fromMap(Map<String, dynamic> map) {
    final types = <String>[];
    final units = <String>[];

    for (final t in asJsonList(map['allowed_price_types'])) {
      if (t != null) types.add(t.toString());
    }

    for (final u in asJsonList(map['allowed_price_units'])) {
      if (u != null) units.add(u.toString());
    }

    return PricingSchemaModel(
      requirement: _parseRequirement(
        (map['pricing_requirement'] ?? 'optional').toString(),
      ),
      allowedTypes: types,
      allowedUnits: units,
    );
  }
}
