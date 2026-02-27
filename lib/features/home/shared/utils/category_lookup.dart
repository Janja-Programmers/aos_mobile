import 'package:africaonlinestores/features/catalog/domain/category_node.dart';

String? findParentCategoryIdByNames(
  List<CategoryNode> parents,
  List<String> targetNames,
) {
  if (parents.isEmpty || targetNames.isEmpty) {
    return null;
  }

  final normalizedTargets = targetNames
      .map((e) => e.trim().toLowerCase())
      .toSet();

  for (final parent in parents) {
    final parentName = parent.name.trim().toLowerCase();

    if (normalizedTargets.contains(parentName)) {
      return parent.id;
    }
  }

  return null;
}
