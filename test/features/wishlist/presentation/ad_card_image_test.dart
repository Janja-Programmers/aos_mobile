import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/wishlist/controller/wishlist_controller.dart';
import 'package:africaonlinestores/features/wishlist/controller/wishlist_state.dart';
import 'package:africaonlinestores/shared/components/cards/widgets/ad_card_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets(
    'uses backend fallback, exposes semantics, and does not overflow at 200% text',
    (tester) async {
      final semantics = tester.ensureSemantics();
      addTearDown(semantics.dispose);

      await tester.pumpTestApp(
        const MediaQuery(
          data: MediaQueryData(
            size: Size(320, 640),
            textScaler: TextScaler.linear(2),
          ),
          child: SizedBox(
            width: 160,
            child: AdCardImage(ad: _wishlistedAd, height: 120),
          ),
        ),
        overrides: <Override>[
          isAuthenticatedProvider.overrideWithValue(true),
          wishlistControllerProvider.overrideWith(
            () => _SeededWishlistController(WishlistState.initial()),
          ),
        ],
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.bySemanticsLabel('Remove from wishlist'), findsOneWidget);
      expect(tester.getSize(find.byType(InkWell)), const Size(48, 48));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('temporary override takes precedence over backend fallback', (
    tester,
  ) async {
    await tester.pumpTestApp(
      const SizedBox(
        width: 160,
        child: AdCardImage(ad: _wishlistedAd, height: 120),
      ),
      overrides: <Override>[
        isAuthenticatedProvider.overrideWithValue(true),
        wishlistControllerProvider.overrideWith(
          () => _SeededWishlistController(
            WishlistState(
              overrides: <String, bool>{'AD-001': false},
            ),
          ),
        ),
      ],
    );

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

class _SeededWishlistController extends WishlistController {
  _SeededWishlistController(this.seed);

  final WishlistState seed;

  @override
  WishlistState build() => seed;
}

const _wishlistedAd = AOSAdListItem(
  id: 'AD-001',
  title: 'Test ad',
  country: 'KE',
  locationName: 'Nairobi',
  categoryName: 'Test',
  currentPrice: '100',
  originalPrice: '100',
  offerPercent: 0,
  isOfferActive: false,
  priceType: 'Fixed',
  priceUnit: '',
  primaryImage: '',
  createdAt: null,
  isWishlisted: true,
  averageRating: 0,
  totalReviews: 0,
);
