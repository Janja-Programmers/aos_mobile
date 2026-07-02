import 'package:africaonlinestores/core/utils/json_utils.dart';
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

  factory AdAttributeModel.fromMap(Map<String, dynamic> map) {
    final options = <String>[];

    for (final o in asJsonList(map['options'])) {
      if (o != null) options.add(o.toString());
    }

    return AdAttributeModel(
      id: (map['id'] ?? '').toString(),
      key: (map['key'] ?? '').toString(),
      label: (map['label'] ?? '').toString(),
      type: _parseType((map['type'] ?? '').toString()),
      required: asBool(map['required']),
      unit: map['unit']?.toString(),
      helpText: map['help_text']?.toString(),
      options: options,
      sortOrder: asInt(map['sort_order']),
    );
  }
}
