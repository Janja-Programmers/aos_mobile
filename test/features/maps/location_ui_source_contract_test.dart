import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seller-specific map route is separated from generic explorer', () {
    final routes = File(
      'lib/features/maps/navigation/maps_routes.dart',
    ).readAsStringSync();
    expect(routes, contains('SellerMapScreen(sellerId: sellerId)'));
  });

  test('store customization no longer owns storefront location editing', () {
    final source = File(
      'lib/features/sellers/presentation/store_customization_screen.dart',
    ).readAsStringSync();
    expect(source, isNot(contains("label: 'Store Location'")));
    expect(source, isNot(contains('_openLocationEditor')));
  });

  test(
    'store banner source chooser uses a dialog rather than a bottom sheet',
    () {
      final source = File(
        'lib/features/sellers/presentation/widgets/store_customization/store_image_source_sheet.dart',
      ).readAsStringSync();
      expect(source, contains('showDialog<_StoreImageSource>'));
      expect(
        source,
        isNot(contains('showModalBottomSheet<_StoreImageSource>')),
      );
    },
  );

  test('seller map nearby toggle is stateful without changing its label', () {
    final source = File(
      'lib/features/maps/presentation/screens/seller_map_screen.dart',
    ).readAsStringSync();

    expect(source, contains("label: const Text('Nearby sellers')"));
    expect(source, isNot(contains("'Nearby on'")));
    expect(source, contains('backgroundColor: _showNearby'));
    expect(source, contains('colors.textPrimary'));
    expect(source, contains('colors.white'));
  });

  test('nearby seller pins navigate to the seller storefront', () {
    final source = File(
      'lib/features/maps/presentation/screens/seller_map_screen.dart',
    ).readAsStringSync();

    expect(source, contains('controller.onCircleTapped.add'));
    expect(source, contains('matched is SellerPinPoint'));
    expect(
      source,
      contains('SellerNavigation.toSellerStore(context, sellerId)'),
    );
  });

  test('filled buttons use the theme white foreground', () {
    final sellerMap = File(
      'lib/features/maps/presentation/screens/seller_map_screen.dart',
    ).readAsStringSync();
    final adLocation = File(
      'lib/features/home/presentation/components/ad_details/seller_location_section.dart',
    ).readAsStringSync();
    final locationEditor = File(
      'lib/features/sellers/location/presentation/screens/seller_location_screen.dart',
    ).readAsStringSync();

    expect(sellerMap, contains('foregroundColor: colors.white'));
    expect(sellerMap, contains('foregroundColor: context.appColors.white'));
    expect(adLocation, contains('foregroundColor: colors.white'));
    expect(locationEditor, contains('foregroundColor: colors.white'));
  });

  test('patched MapLibre surfaces suppress Android native info chrome', () {
    final chrome = File(
      'lib/features/maps/presentation/widgets/maplibre_platform_chrome.dart',
    ).readAsStringSync();
    final sellerMap = File(
      'lib/features/maps/presentation/screens/seller_map_screen.dart',
    ).readAsStringSync();
    final adLocation = File(
      'lib/features/home/presentation/components/ad_details/seller_location_section.dart',
    ).readAsStringSync();
    final locationEditor = File(
      'lib/features/sellers/location/presentation/screens/seller_location_screen.dart',
    ).readAsStringSync();

    expect(chrome, contains('TargetPlatform.android'));
    expect(chrome, contains('Point<num>(-96, -96)'));
    for (final source in <String>[sellerMap, adLocation, locationEditor]) {
      expect(source, contains('attributionButtonMargins:'));
      expect(source, contains('aosMapAttributionButtonMargins'));
    }
  });
}
