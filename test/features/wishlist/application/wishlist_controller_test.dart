import 'dart:async';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage.dart';
import 'package:africaonlinestores/core/storage/onboarding_storage_provider.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/ads/data/ads_api.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/features/auth/data/auth_api.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/wishlist/controller/wishlist_controller.dart';
import 'package:africaonlinestores/features/wishlist/controller/wishlist_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_session_storage.dart';
import '../../../helpers/provider_container.dart';
import '../../../helpers/test_preferences.dart';
import '../../../test_config/test_environment.dart';
import '../../account_profile/fakes/mutable_auth_controller.dart';

void main() {
  test('provider performs no eager wishlist network request', () async {
    final harness = await _buildHarness(
      toggleHandler: ({required String adId, required bool wishlisted}) async {
        return _success(adId: adId, wishlisted: wishlisted);
      },
    );

    final state = harness.container.read(wishlistControllerProvider);

    expect(state.overrides, isEmpty);
    expect(state.pending, isEmpty);
    expect(harness.api.listCalls, 0);
    expect(harness.api.toggleCalls, 0);
  });

  test(
    'optimistically updates, blocks duplicates, and confirms backend state',
    () async {
      final completer = Completer<Either<Failure, Map<String, dynamic>>>();
      final harness = await _buildHarness(
        toggleHandler: ({required String adId, required bool wishlisted}) {
          return completer.future;
        },
      );
      final controller = harness.container.read(
        wishlistControllerProvider.notifier,
      );

      final first = controller.toggle('AD-001', currentValue: false);
      await Future<void>.delayed(Duration.zero);

      WishlistState state = harness.container.read(wishlistControllerProvider);
      expect(state.resolve('AD-001', fallback: false), isTrue);
      expect(state.pending, contains('AD-001'));
      expect(harness.api.toggleCalls, 1);
      expect(harness.api.lastWishlisted, isTrue);

      final duplicate = await controller.toggle('AD-001', currentValue: false);
      expect(duplicate, isFalse);
      expect(harness.api.toggleCalls, 1);

      completer.complete(_success(adId: 'AD-001', wishlisted: true));
      expect(await first, isTrue);

      state = harness.container.read(wishlistControllerProvider);
      expect(state.resolve('AD-001', fallback: false), isTrue);
      expect(state.pending, isNot(contains('AD-001')));
    },
  );

  test('rolls back the optimistic override after a failure', () async {
    final harness = await _buildHarness(
      toggleHandler: ({required String adId, required bool wishlisted}) async {
        return Either<Failure, Map<String, dynamic>>.left(
          const Failure('Network unavailable.'),
        );
      },
    );
    final controller = harness.container.read(
      wishlistControllerProvider.notifier,
    );

    final result = await controller.toggle('AD-002', currentValue: false);

    expect(result, isFalse);
    final state = harness.container.read(wishlistControllerProvider);
    expect(state.resolve('AD-002', fallback: false), isFalse);
    expect(state.overrides.containsKey('AD-002'), isFalse);
    expect(state.pending, isEmpty);
  });

  test('uses the backend response as the final authority', () async {
    final harness = await _buildHarness(
      toggleHandler: ({required String adId, required bool wishlisted}) async {
        return _success(adId: adId, wishlisted: false);
      },
    );
    final controller = harness.container.read(
      wishlistControllerProvider.notifier,
    );

    final result = await controller.toggle('AD-003', currentValue: false);

    expect(result, isTrue);
    final state = harness.container.read(wishlistControllerProvider);
    expect(state.resolve('AD-003', fallback: true), isFalse);
  });

  test('clears account-scoped overrides when authentication changes', () async {
    final harness = await _buildHarness(
      toggleHandler: ({required String adId, required bool wishlisted}) async {
        return _success(adId: adId, wishlisted: wishlisted);
      },
    );
    final controller = harness.container.read(
      wishlistControllerProvider.notifier,
    );

    await controller.toggle('AD-004', currentValue: false);
    expect(
      harness.container
          .read(wishlistControllerProvider)
          .resolve('AD-004', fallback: false),
      isTrue,
    );

    harness.authController.replace(const AuthGuest());
    await Future<void>.delayed(Duration.zero);

    expect(
      harness.container.read(wishlistControllerProvider).overrides,
      isEmpty,
    );
  });
}

typedef WishlistToggleHandler =
    Future<Either<Failure, Map<String, dynamic>>> Function({
      required String adId,
      required bool wishlisted,
    });

class _ScriptedWishlistAdsApi extends AdsApi {
  _ScriptedWishlistAdsApi(super.client, {required this.toggleHandler});

  final WishlistToggleHandler toggleHandler;
  int listCalls = 0;
  int toggleCalls = 0;
  bool? lastWishlisted;

  @override
  Future<Either<Failure, Map<String, dynamic>>> listWishlist({
    int limit = 20,
    int offset = 0,
    String? sort,
    String? q,
    int? priceMin,
    int? priceMax,
    int? ratingMin,
    bool? verifiedSeller,
  }) async {
    listCalls += 1;
    return Either<Failure, Map<String, dynamic>>.right(const <String, dynamic>{
      'ok': true,
      'data': <String, dynamic>{'items': <Object?>[]},
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> toggleWishlist({
    required String adId,
    required bool wishlisted,
  }) {
    toggleCalls += 1;
    lastWishlisted = wishlisted;
    return toggleHandler(adId: adId, wishlisted: wishlisted);
  }
}

class _WishlistHarness {
  const _WishlistHarness({
    required this.container,
    required this.api,
    required this.authController,
  });

  final ProviderContainer container;
  final _ScriptedWishlistAdsApi api;
  final MutableAuthController authController;
}

Future<_WishlistHarness> _buildHarness({
  required WishlistToggleHandler toggleHandler,
}) async {
  final preferences = await setUpTestPreferences();
  final onboardingStorage = OnboardingStorage(preferences);
  final storage = FakeSessionStorage(sid: TestEnvironment.sessionId);
  late _ScriptedWishlistAdsApi api;
  late MutableAuthController authController;

  final container = createTestContainer(
    overrides: <Override>[
      onboardingStorageProvider.overrideWithValue(onboardingStorage),
      adsApiProvider.overrideWith((Ref ref) {
        // ignore: join_return_with_assignment
        api = _ScriptedWishlistAdsApi(
          ref.read(_testApiClientProvider),
          toggleHandler: toggleHandler,
        );
        return api;
      }),
      authControllerProvider.overrideWith((Ref ref) {
        final resolvedClient = ref.read(_testApiClientProvider);
        // ignore: join_return_with_assignment
        authController = MutableAuthController(
          ref: ref,
          api: AuthApi(resolvedClient),
          apiClient: resolvedClient,
          storage: storage,
          initialState: AuthAuthenticated(
            user: AuthUser(
              email: TestEnvironment.userEmail,
              fullName: 'Test User',
            ),
            sid: TestEnvironment.sessionId,
          ),
        );
        return authController;
      }),
      _testApiClientProvider.overrideWith((Ref ref) {
        final client = ApiClient(baseUrl: TestEnvironment.apiBaseUrl, ref: ref);
        ref.onDispose(client.dispose);
        return client;
      }),
    ],
  );

  container.read(wishlistControllerProvider);
  container.read(adsApiProvider);
  return _WishlistHarness(
    container: container,
    api: api,
    authController: authController,
  );
}

final _testApiClientProvider = Provider<ApiClient>((Ref ref) {
  throw StateError('The test API client must be overridden.');
});

Either<Failure, Map<String, dynamic>> _success({
  required String adId,
  required bool wishlisted,
}) {
  return Either<Failure, Map<String, dynamic>>.right(<String, dynamic>{
    'ok': true,
    'data': <String, dynamic>{
      'ad_id': adId,
      'wishlisted': wishlisted,
      'changed': true,
    },
  });
}
