import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('edit and draft forms gate stateful steps behind preload', () {
    final screen = File(
      'lib/features/ads/ads_form/presentation/screens/ad_form_screen.dart',
    ).readAsStringSync();

    final postFrame = screen.indexOf(
      'WidgetsBinding.instance.addPostFrameCallback',
    );
    final initialLoad = screen.indexOf('unawaited(_loadInitialDraft())');
    final providerReset = screen.indexOf(
      'ref.read(adFormControllerProvider(widget.mode).notifier).reset()',
    );

    expect(postFrame, greaterThanOrEqualTo(0));
    expect(initialLoad, greaterThan(postFrame));
    expect(providerReset, greaterThan(initialLoad));
    expect(screen, contains('bool _initializing = true'));
    expect(screen, contains('if (_initializing)'));
    expect(screen, contains('_requiresPreload && draftAsync.isLoading'));
    expect(screen, contains('_requiresPreload && draftAsync.hasError'));
    expect(screen, contains('schemaAsync.isLoading'));
    expect(screen, contains('schemaAsync.hasError'));
    expect(
      screen,
      contains('AdFormStepsBuilder.build(schema: schema, mode: widget.mode)'),
    );
    expect(screen, isNot(contains('.maybeWhen(')));
  });

  test('draft controller rejects stale preload responses', () {
    final controller = File(
      'lib/features/ads/shared/providers/ad_draft_controller.dart',
    ).readAsStringSync();

    expect(controller, contains('int _loadGeneration = 0'));
    expect(controller, contains('final generation = _beginLoad()'));
    expect(controller, contains('if (!_isCurrentLoad(generation)) return'));
    expect(controller, contains("asJsonMap(response['data'])"));
    expect(controller, contains("asJsonMap(data['item'])"));
  });

  test('form step validation uses the active create or edit mode', () {
    final basic = File(
      'lib/features/ads/ads_form/presentation/steps/basic_step.dart',
    ).readAsStringSync();
    final description = File(
      'lib/features/ads/ads_form/presentation/steps/description_step.dart',
    ).readAsStringSync();

    expect(basic, contains('adFormControllerProvider(widget.mode)'));
    expect(description, contains('adFormControllerProvider(widget.mode)'));
    expect(
      basic,
      isNot(contains('adFormControllerProvider(AdFormMode.create)')),
    );
    expect(
      description,
      isNot(contains('adFormControllerProvider(AdFormMode.create)')),
    );
  });

  test('reduced edit follows backend status and pricing metadata', () {
    final screen = File(
      'lib/features/ads/ads_form/presentation/screens/'
      'reduced_edit_listing_screen.dart',
    ).readAsStringSync();

    expect(screen, contains("_optionalPositiveDouble(item['offer_price'])"));
    expect(screen, contains("asJsonMap(item['pricing'])"));
    expect(screen, contains("asString(item['status']).trim()"));
    expect(screen, contains('AdUpdateContract.payloadForStatus'));
    expect(screen, contains('_pricingPayload(includeClears: true)'));
    expect(screen, contains('validator: _validateTitle'));
    expect(screen, contains('validator: _validateDescription'));
    expect(screen, contains('validator: _validatePrice'));
    expect(screen, contains('validator: _validateOfferPrice'));
    expect(screen, contains('_offerStart!.isAfter(_offerEnd!)'));
  });
}
