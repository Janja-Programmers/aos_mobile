import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('homepage taxonomy has no fixed category-name configuration', () {
    final sections = File(
      'lib/features/home/domain/home_ads_sections.dart',
    ).readAsStringSync();
    final content = File(
      'lib/features/home/presentation/sections/ads_content.dart',
    ).readAsStringSync();
    final helpers = File('lib/shared/utils/helpers.dart').readAsStringSync();

    const retiredTaxonomy = <String>[
      "'Services'",
      "'Electronics'",
      "'Home, Furniture & Appliances'",
      "'Men\\'s Fashion'",
      '"Women\'s Fashion"',
      "'Babies & Kids'",
      "'Beauty & Personal Care'",
      "'Garden Supplies'",
    ];

    for (final literal in retiredTaxonomy) {
      expect(sections, isNot(contains(literal)));
      expect(content, isNot(contains(literal)));
    }

    expect(sections, isNot(contains('preferredCategoryNames')));
    expect(content, isNot(contains('preferredCategoryNames')));
    expect(helpers, isNot(contains("case 'electronics'")));
    expect(helpers, isNot(contains("case 'fashion'")));
    expect(helpers, isNot(contains("case 'kids'")));
    expect(helpers, isNot(contains("case 'beauty'")));
  });

  test(
    'HomePageController owns dynamic category rails using canonical ids',
    () {
      final controller = File(
        'lib/features/home/presentation/controller/home_page_controller.dart',
      ).readAsStringSync();
      final content = File(
        'lib/features/home/presentation/sections/ads_content.dart',
      ).readAsStringSync();

      expect(controller, contains('ref.watch(categoriesControllerProvider)'));
      expect(controller, contains('selectHomeCategories('));
      expect(controller, contains('categoryId: section.categoryId'));
      expect(controller, contains('_inFlightRequests'));
      expect(controller, isNot(contains('.join(\',\')')));
      expect(content, contains('categoryId: category.id'));
      expect(content, contains('section.title ?? homeSectionTitle'));
    },
  );

  test('legacy section provider cannot create a competing network owner', () {
    final provider = File(
      'lib/features/home/shared/providers/home_section_ads_provider.dart',
    ).readAsStringSync();
    final lookup = File(
      'lib/features/home/shared/utils/category_lookup.dart',
    ).readAsStringSync();

    expect(provider, contains('homePageControllerProvider.future'));
    expect(provider, isNot(contains('adsApiProvider')));
    expect(provider, isNot(contains('categoriesControllerProvider')));
    expect(provider, isNot(contains('findParentCategoryIdByNames')));
    expect(lookup, isNot(contains('findParentCategoryIdByNames')));
  });

  test('top category preview remains backend ordered and unshuffled', () {
    final source = File(
      'lib/features/home/presentation/components/'
      'home_categories_preview_section.dart',
    ).readAsStringSync();

    expect(source, contains('categoriesControllerProvider'));
    expect(source, contains('state.parents.take(limit)'));
    expect(source, isNot(contains('.shuffle(')));
  });
}
