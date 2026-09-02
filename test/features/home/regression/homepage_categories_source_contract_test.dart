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

  test('retired Home compatibility files stay deleted', () {
    const retiredPaths = <String>[
      'lib/features/home/shared/providers/home_section_ads_provider.dart',
      'lib/features/home/shared/providers/home_page_providers.dart',
      'lib/features/home/domain/market_place.dart',
      'lib/features/home/shared/utils/category_lookup.dart',
    ];

    for (final path in retiredPaths) {
      expect(File(path).existsSync(), isFalse, reason: '$path must stay retired');
    }
  });

  test('retired fixed-taxonomy localization keys stay deleted', () {
    const retiredKeys = <String>[
      'home_services_near_you',
      'home_electronic_deals',
      'home_furniture',
      'home_electronics',
      'home_fashion',
      'home_babies_kids',
      'home_beauty',
    ];

    final arbFiles = Directory('lib/l10n/arb')
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.arb'));

    for (final file in arbFiles) {
      final source = file.readAsStringSync();
      for (final key in retiredKeys) {
        expect(
          source,
          isNot(contains('"$key"')),
          reason: '$key must stay retired in ${file.path}',
        );
        expect(
          source,
          isNot(contains('"@$key"')),
          reason: '@$key must stay retired in ${file.path}',
        );
      }
    }
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
