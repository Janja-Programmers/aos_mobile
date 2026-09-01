import 'dart:io';

import 'package:africaonlinestores/features/shorts/feeds/application/state/following/folllowing_section_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seller suggestion uses backend display_name instead of shop_name', () {
    final suggestion = SellerSuggestion.fromJson(<String, dynamic>{
      'seller': 'SEL-123',
      'display_name': 'Jane Friend',
      'shop_name': 'Ignored Shop Name',
      'avatar': '/files/jane.jpg',
      'total_followers': 27,
      'is_following': false,
    });

    expect(suggestion.sellerId, 'SEL-123');
    expect(suggestion.displayName, 'Jane Friend');
    expect(suggestion.initials, 'JF');
    expect(suggestion.totalFollowers, 27);
  });

  test('missing display_name has a privacy-safe account fallback', () {
    final suggestion = SellerSuggestion.fromJson(<String, dynamic>{
      'seller_id': 'SEL-456',
      'display_name': '   ',
      'total_followers': 0,
      'is_following': false,
    });

    expect(suggestion.sellerId, 'SEL-456');
    expect(suggestion.displayName, 'AOS User');
    expect(suggestion.initials, 'AU');
  });

  test('suggested card does not use the global full-width 56px button', () {
    final source = File(
      'lib/features/shorts/feeds/presentation/components/following/'
      'following_sellers_card.dart',
    ).readAsStringSync();

    expect(source, contains('seller.displayName'));
    expect(source, contains('minimumSize: const Size(96, 40)'));
    expect(source, isNot(contains('width: double.infinity')));
    expect(source, contains('MaterialTapTargetSize.padded'));
  });
}
