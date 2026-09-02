import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/home/domain/home_ads_sections.dart';
import 'package:africaonlinestores/features/home/domain/home_category_selection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const List<CategoryNode> categories = <CategoryNode>[
    CategoryNode(id: 'CAT-1', name: 'One', isGroup: true),
    CategoryNode(id: 'CAT-2', name: 'Two', isGroup: true),
    CategoryNode(id: 'CAT-3', name: 'Three', isGroup: true),
    CategoryNode(id: 'CAT-4', name: 'Four', isGroup: true),
    CategoryNode(id: 'CAT-5', name: 'Five', isGroup: true),
  ];

  test('same seed produces stable category selection', () {
    final first = selectHomeCategories(categories, seed: 'market:session:0');
    final second = selectHomeCategories(categories, seed: 'market:session:0');

    expect(
      first.map((CategoryNode category) => category.id),
      second.map((CategoryNode category) => category.id),
    );
  });

  test('selection is unique, capped at four, and does not mutate input', () {
    final originalIds = categories
        .map((CategoryNode category) => category.id)
        .toList(growable: false);
    final withDuplicate = <CategoryNode>[...categories, categories.first];

    final selected = selectHomeCategories(
      withDuplicate,
      seed: 'market:session:1',
    );

    expect(selected, hasLength(4));
    expect(
      selected.map((CategoryNode category) => category.id).toSet(),
      hasLength(4),
    );
    expect(categories.map((CategoryNode category) => category.id), originalIds);
  });

  test('fewer than four categories returns only available categories', () {
    final selected = selectHomeCategories(
      categories.take(2).toList(growable: false),
      seed: 'market:session:2',
    );

    expect(selected, hasLength(2));
    expect(
      selected.map((CategoryNode category) => category.id).toSet(),
      <String>{'CAT-1', 'CAT-2'},
    );
  });

  test('empty input and non-positive limit return empty selection', () {
    expect(selectHomeCategories(const <CategoryNode>[], seed: 'seed'), isEmpty);
    expect(selectHomeCategories(categories, seed: 'seed', limit: 0), isEmpty);
  });

  test('dynamic sections preserve canonical id separately from title', () {
    const category = CategoryNode(
      id: 'CAT-CANONICAL',
      name: 'Renamable display label',
      isGroup: true,
    );

    final sections = buildHomeAdsSections(const <CategoryNode>[category]);
    final dynamicSection = sections.singleWhere(
      (section) => section.isCategorySection,
    );

    expect(dynamicSection.categoryId, 'CAT-CANONICAL');
    expect(dynamicSection.title, 'Renamable display label');
    expect(dynamicSection.key, 'category:CAT-CANONICAL');
  });
}
