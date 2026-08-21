import 'package:africaonlinestores/core/utils/json_utils.dart';

class CategoryNode {
  const CategoryNode({
    required this.id,
    required this.name,
    required this.isGroup,
    this.icon,
    this.iconMediaId,
    this.parentId,
    this.sortOrder = 0,
    this.children = const <CategoryNode>[],
  });

  final String id;
  final String name;
  final bool isGroup;
  final String? icon;
  final String? iconMediaId;
  final String? parentId;
  final int sortOrder;
  final List<CategoryNode> children;

  bool get isSellable => !isGroup;

  factory CategoryNode.fromJson(Map<String, dynamic> json) {
    final String id = _requiredText(json, 'id');
    final String name = _requiredText(json, 'name');
    final Object? childrenValue = json['children'];
    if (childrenValue is! List<Object?>) {
      throw const FormatException('Category children must be a list.');
    }

    final List<CategoryNode> children = <CategoryNode>[];
    for (final Object? childValue in childrenValue) {
      if (childValue is! Map<Object?, Object?>) {
        throw const FormatException('Category child must be an object.');
      }
      children.add(CategoryNode.fromJson(asJsonMap(childValue)));
    }

    return CategoryNode(
      id: id,
      name: name,
      isGroup: _flag(json['is_group']),
      icon: _nullableText(json['icon']),
      iconMediaId:
          _nullableText(json['icon_media_id']) ??
          _nullableText(json['icon_media']),
      parentId: _nullableText(json['parent_id']),
      sortOrder: _sortOrder(json['sort_order']),
      children: List<CategoryNode>.unmodifiable(children),
    );
  }
}

String _requiredText(Map<String, dynamic> json, String key) {
  final String value = _nullableText(json[key]) ?? '';
  if (value.isEmpty) {
    throw FormatException('Category $key is required.');
  }
  return value;
}

String? _nullableText(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is! String) {
    throw const FormatException('Category text fields must be strings.');
  }
  final String normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

int _sortOrder(Object? value) {
  final int? parsed = asNullableInt(value);
  if (parsed == null || parsed < 0) {
    throw const FormatException('Category sort_order is invalid.');
  }
  return parsed;
}

bool _flag(Object? value) {
  if (value == 1) {
    return true;
  }
  if (value == 0) {
    return false;
  }
  throw const FormatException('Category is_group is invalid.');
}
