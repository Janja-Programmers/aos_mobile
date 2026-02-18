import 'package:africaonlinestores/features/catalog/domain/category_node.dart';

String? findCategoryIdByNames(
  List<CategoryNode> roots,
  List<String> preferredNames,
) {
  if (roots.isEmpty || preferredNames.isEmpty) return null;

  final wanted = preferredNames
      .map((e) => e.trim().toLowerCase())
      .where((e) => e.isNotEmpty)
      .toList();
  if (wanted.isEmpty) return null;

  CategoryNode? match;

  void visit(CategoryNode node) {
    if (match != null) return;
    final n = node.name.trim().toLowerCase();
    if (wanted.contains(n) || wanted.any((w) => n.contains(w))) {
      match = node;
      return;
    }
    for (final c in node.children) {
      visit(c);
      if (match != null) return;
    }
  }

  for (final r in roots) {
    visit(r);
    if (match != null) break;
  }

  return match?.id;
}
