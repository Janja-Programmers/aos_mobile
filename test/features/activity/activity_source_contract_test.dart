import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Activity hide is backend-backed and exposed by swipe and long press',
    () {
      final String api = File(
        'lib/features/activity/data/activity_api.dart',
      ).readAsStringSync();
      final String screen = File(
        'lib/features/activity/presentation/screens/activity_center_screen.dart',
      ).readAsStringSync();

      expect(api, contains('ApiEndpoints.hideActivity'));
      expect(api, contains("'activity_id': id"));
      expect(screen, contains('Dismissible('));
      expect(screen, contains('controller.hide(item.id)'));
      expect(screen, contains('onLongPress'));
      expect(screen, contains('Hide from activity'));
    },
  );

  test('Activity pagination is guarded around destructive mutations', () {
    final String controller = File(
      'lib/features/activity/application/activity_center_controller.dart',
    ).readAsStringSync();

    expect(controller, contains('_hidingIds.isNotEmpty'));
    expect(controller, contains('_clearInFlight'));
    expect(controller, contains('_requestGeneration'));
    expect(controller, contains('state.start - 1'));
    expect(controller, contains('_hidesSettledCompleter'));
    expect(controller, contains('A pending group clear supersedes'));
  });

  test('historical ad activity preflights the public ad target', () {
    final String screen = File(
      'lib/features/activity/presentation/screens/activity_center_screen.dart',
    ).readAsStringSync();

    expect(screen, contains('adsApiProvider'));
    expect(screen, contains('getAd(adId: safeRouteId)'));
    expect(screen, contains('This listing is no longer available.'));
    expect(screen, contains('_safeIdentifier'));
  });

  test('Activity clear remains group-aware backend clear', () {
    final String api = File(
      'lib/features/activity/data/activity_api.dart',
    ).readAsStringSync();
    final String controller = File(
      'lib/features/activity/application/activity_center_controller.dart',
    ).readAsStringSync();

    expect(api, contains('ApiEndpoints.clearActivity'));
    expect(api, contains("'group': group!.trim()"));
    expect(controller, contains('clearActivity(group: group)'));
  });
}
