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
      // Some backends send newline/comma separated options.
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
    this.meta = const <String, dynamic>{},
  });

  final PricingRequirement requirement;
  final bool isService;
  final List<String> allowedTypes;
  final List<String> allowedUnits;

  /// Any additional backend hints/flags we don't model yet.
  final Map<String, dynamic> meta;

  static PricingRequirement _parseRequirement(String raw) {
    final v = raw.trim().toLowerCase();
    if (v == 'hidden') return PricingRequirement.hidden;
    if (v == 'required') return PricingRequirement.required;
    if (v == 'optional') return PricingRequirement.optional;
    return PricingRequirement.optional;
  }

  static PricingSchema fromAny(dynamic raw) {
    if (raw is Map) {
      final m = Map<String, dynamic>.from(raw);

      final req = _parseRequirement(
        (m['requirement'] ?? m['mode'] ?? 'optional').toString(),
      );

      final types = <String>[];
      final units = <String>[];

      if (m['allowed_price_types'] is List) {
        for (final t in (m['allowed_price_types'] as List)) {
          if (t == null) continue;
          types.add(t.toString());
        }
      }

      if (m['price_units'] is List) {
        for (final u in (m['price_units'] as List)) {
          if (u == null) continue;
          units.add(u.toString());
        }
      }

      /// ✅ PARSE is_service
      final isService =
          m['is_service'] == true ||
          m['isService'] == true ||
          m['service'] == true;

      return PricingSchema(
        requirement: req,
        allowedTypes: types,
        allowedUnits: units,
        isService: isService,
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
    // We try multiple key shapes because backend is source of truth and may evolve.
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
