import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Ad form always enters the category picker at the root list', () {
    final String source = File(
      'lib/features/ads/ads_form/presentation/steps/basic_step.dart',
    ).readAsStringSync();
    final String categoryTapBody = source
        .split("placeholder: 'Select a category'")
        .last
        .split('if (res == null) return;')
        .first;

    expect(categoryTapBody, contains('AppRoutes.nSelectCategory'));
    expect(categoryTapBody, isNot(contains('extra:')));
    expect(categoryTapBody, isNot(contains('parentNode')));
    expect(source, isNot(contains('categoriesControllerProvider')));
  });

  test('selecting a backend group pushes its child-category route', () {
    final String source = File(
      'lib/features/ads/ads_form/presentation/pickers/'
      'select_category_screen.dart',
    ).readAsStringSync();

    expect(source, contains('final isGroup = n.isGroup;'));
    expect(source, contains('if (isGroup) {'));
    expect(source, contains('context.push<Map<String, dynamic>>('));
    expect(source, contains('AppRoutes.selectCategory'));
    expect(source, contains('extra: n'));
  });
}
