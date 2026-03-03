enum PricingRequirement { hidden, optional, required }

enum AdAttributeType {
  text,
  number,
  select,
  multiselect,
  boolean,
  date,
  year,
  unknown,
}

class AdAttributeSchema {
  AdAttributeSchema({
    required this.key,
    required this.label,
    required this.type,
    this.required = false,
    this.options = const <String>[],
  });

  final String key;
  final String label;
  final AdAttributeType type;
  final bool required;
  final List<String> options;

  static AdAttributeType _parseType(String raw) {
    final t = raw.trim().toLowerCase();
    switch (t) {
      case 'text':
      case 'string':
        return AdAttributeType.text;
      case 'number':
      case 'float':
      case 'int':
      case 'integer':
        return AdAttributeType.number;
      case 'select':
      case 'dropdown':
        return AdAttributeType.select;
      case 'multiselect':
      case 'multi_select':
        return AdAttributeType.multiselect;
      case 'bool':
      case 'boolean':
        return AdAttributeType.boolean;
      case 'date':
        return AdAttributeType.date;
      case 'year':
        return AdAttributeType.year;
      default:
        return AdAttributeType.unknown;
    }
  }

  static AdAttributeSchema? fromAnyMap(Map<String, dynamic> m) {
    final key = (m['key'] ?? m['code'] ?? m['name'] ?? m['id'] ?? '')
        .toString();
    if (key.isEmpty) return null;
    final label = (m['label'] ?? m['title'] ?? m['name'] ?? key).toString();
    final type = _parseType((m['type'] ?? m['field_type'] ?? '').toString());
    final required = m['required'] == true || m['is_required'] == true;
    final options = <String>[];
    final raw = m['options'] ?? m['choices'];

    if (raw is List) {
      for (final o in raw) {
        if (o == null) continue;
        options.add(o.toString());
      }
    } else if (raw is String && raw.trim().isNotEmpty) {
      final parts = raw.contains('\n') ? raw.split('\n') : raw.split(',');
      for (final p in parts) {
        final v = p.trim();
        if (v.isNotEmpty) options.add(v);
      }
    }

    return AdAttributeSchema(
      key: key,
      label: label,
      type: type,
      required: required,
      options: options,
    );
  }
}

class PricingSchema {
  const PricingSchema({
    required this.requirement,
    this.allowedTypes = const <String>[],
    this.allowedUnits = const <String>[],
    this.isService = false,
    this.showPriceUnit = false,
    this.meta = const <String, dynamic>{},
  });

  final PricingRequirement requirement;
  final bool isService;
  final bool showPriceUnit;
  final List<String> allowedTypes;
  final List<String> allowedUnits;

  /// Any additional backend hints/flags we don't model yet.
  final Map<String, dynamic> meta;

  static PricingRequirement _parseRequirement(String raw) {
    final v = raw.trim().toLowerCase();
    switch (v) {
      case 'hidden':
        return PricingRequirement.hidden;
      case 'required':
        return PricingRequirement.required;
      case 'optional':
      default:
        return PricingRequirement.optional;
    }
  }

  static bool _parseBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v == 1;
    if (v is String) {
      final val = v.toLowerCase();
      return val == 'true' || val == '1';
    }
    return false;
  }

  static PricingSchema fromAny(dynamic raw) {
    if (raw is Map) {
      final m = Map<String, dynamic>.from(raw);

      // ✅ FIX 1: Correct key mapping
      final req = _parseRequirement(
        (m['pricing_requirement'] ??
                m['requirement'] ??
                m['mode'] ??
                'optional')
            .toString(),
      );

      // ✅ FIX 2: Correct allowed types
      final types = <String>[];
      if (m['allowed_price_types'] is List) {
        for (final t in (m['allowed_price_types'] as List)) {
          if (t == null) continue;
          types.add(t.toString());
        }
      }

      // ✅ FIX 3: Correct allowed units key
      final units = <String>[];
      if (m['allowed_price_units'] is List) {
        for (final u in (m['allowed_price_units'] as List)) {
          if (u == null) continue;
          units.add(u.toString());
        }
      }

      // ✅ FIX 4: Properly parse is_service (handles 1, true, "1", etc.)
      final isService = _parseBool(
        m['is_service'] ?? m['isService'] ?? m['service'],
      );

      // ✅ FIX 5: show_price_unit flag
      final showPriceUnit = _parseBool(m['show_price_unit']);

      return PricingSchema(
        requirement: req,
        allowedTypes: types,
        allowedUnits: units,
        isService: isService,
        showPriceUnit: showPriceUnit,
        meta: m,
      );
    }

    return const PricingSchema(
      requirement: PricingRequirement.optional,
      isService: false,
    );
  }
}

class AdCategorySchema {
  const AdCategorySchema({
    required this.attributes,
    required this.pricing,
    this.meta = const <String, dynamic>{},
  });

  final List<AdAttributeSchema> attributes;
  final PricingSchema pricing;
  final Map<String, dynamic> meta;

  static AdCategorySchema fromBackendPayload(Map<String, dynamic> payload) {
    final data = (payload['data'] is Map)
        ? Map<String, dynamic>.from(payload['data'] as Map)
        : payload;

    dynamic attrsRaw = data['attributes'] ?? data['details'] ?? data['fields'];
    if (attrsRaw is Map && attrsRaw['attributes'] is List) {
      attrsRaw = attrsRaw['attributes'];
    }
    final attrs = <AdAttributeSchema>[];
    if (attrsRaw is List) {
      for (final item in attrsRaw) {
        if (item is! Map) continue;
        final schema = AdAttributeSchema.fromAnyMap(
          Map<String, dynamic>.from(item),
        );
        if (schema != null) attrs.add(schema);
      }
    }

    final pricingRaw = data['pricing'] ?? data['price'] ?? const {};
    final pricing = PricingSchema.fromAny(pricingRaw);

    return AdCategorySchema(attributes: attrs, pricing: pricing, meta: data);
  }
}
