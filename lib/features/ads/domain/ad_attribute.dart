
import 'package:africaonlinestores/shared/enums/ads.dart';

class AdAttribute {
  const AdAttribute({
    required this.id,
    required this.key,
    required this.label,
    required this.type,
    required this.required,
    this.unit,
    this.helpText,
    this.options = const [],
    this.sortOrder = 0,
  });

  final String id;
  final String key;
  final String label;
  final AdAttributeType type;
  final bool required;
  final String? unit;
  final String? helpText;
  final List<String> options;
  final int sortOrder;
}

class AdAttributeModel extends AdAttribute {
  const AdAttributeModel({
    required super.id,
    required super.key,
    required super.label,
    required super.type,
    required super.required,
    super.unit,
    super.helpText,
    super.options,
    super.sortOrder,
  });

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
        return AdAttributeType.text;
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

  factory AdAttributeModel.fromMap(Map<String, dynamic> map) {
    final options = <String>[];

    if (map['options'] is List) {
      for (final o in map['options']) {
        if (o != null) options.add(o.toString());
      }
    }

    return AdAttributeModel(
      id: (map['id'] ?? '').toString(),
      key: (map['key'] ?? '').toString(),
      label: (map['label'] ?? '').toString(),
      type: _parseType((map['type'] ?? '').toString()),
      required: _parseBool(map['required']),
      unit: map['unit']?.toString(),
      helpText: map['help_text']?.toString(),
      options: options,
      sortOrder: (map['sort_order'] ?? 0) as int,
    );
  }
}
