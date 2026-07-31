import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/theme/app_theme.dart';
import 'package:africaonlinestores/core/theme/theme_controller.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/core/utils/local_resolver.dart';
import 'package:africaonlinestores/features/account/presentation/account_screen.dart';
import 'package:africaonlinestores/features/account/shared/providers/accounts_provider.dart';
import 'package:africaonlinestores/features/auth/data/auth_api.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/verifications/controllers/seller_status_provider.dart';
import 'package:africaonlinestores/features/verifications/domain/verification_status.dart';
import 'package:africaonlinestores/features/verifications/user_verification/application/user_verification_provider.dart';
import 'package:africaonlinestores/features/verifications/user_verification/domain/user_verification_models.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../fakes/fake_session_storage.dart';
import '../../../../fakes/recording_http_client_adapter.dart';
import '../../../../helpers/pump_app.dart';
import '../../fakes/mutable_auth_controller.dart';
import '../../fakes/scripted_accounts_api.dart';
import '../../helpers/account_profile_api_harness.dart';
import '../../helpers/account_profile_fixture.dart';

void main() {
  late AccountProfileApiHarness apiHarness;
  late Map<String, dynamic> ownProfile;

  setUp(() async {
    apiHarness = await buildAccountProfileApiHarness(
      RecordingHttpClientAdapter((_) => jsonResponse(<String, dynamic>{})),
    );
    ownProfile = await loadAccountProfileMessageFixture('own_profile.json');
  });

  tearDown(() => apiHarness.container.dispose());

  List<Override> overrides({
    required bool verified,
    bool isSeller = false,
    String? sellerId,
    String? displayName,
  }) {
    final Map<String, dynamic> profileData =
        Map<String, dynamic>.from(ownProfile['data'] as Map<String, dynamic>)
          ..['is_verified'] = verified
          ..addAll(<String, dynamic>{'display_name': ?displayName});
    final Map<String, dynamic> accountPayload = <String, dynamic>{
      ...ownProfile,
      'data': profileData,
    };
    final ScriptedAccountsApi accountsApi = ScriptedAccountsApi(
      apiHarness.client,
      getProfileHandler: (_) async => Either.right(accountPayload),
    );

    return <Override>[
      themeModeProvider.overrideWith((ref) => ThemeController(ThemeMode.light)),
      accountsApiProvider.overrideWithValue(accountsApi),
      authControllerProvider.overrideWith((Ref ref) {
        return MutableAuthController(
          ref: ref,
          api: AuthApi(apiHarness.client),
          apiClient: apiHarness.client,
          storage: FakeSessionStorage(sid: 'test-session-id'),
          initialState: AuthAuthenticated(
            user: AuthUser(
              accountId: 'ACC-ABCDEFGHIJKLMNOPQRST',
              email: 'owner@example.invalid',
              fullName: 'Test Owner',
              isVerified: verified,
            ),
            sid: 'test-session-id',
            seller: AuthSellerSummary(
              isSeller: isSeller,
              sellerId: sellerId,
              status: isSeller ? 'Active' : null,
            ),
          ),
        );
      }),
      userVerificationStatusProvider.overrideWith((Ref ref) async {
        return UserVerificationStatus(
          isVerified: verified,
          status: verified
              ? VerificationStatus.approved
              : VerificationStatus.notSubmitted,
        );
      }),
      sellerStatusProvider.overrideWith((Ref ref) async {
        return SellerVerificationStatus(
          isSeller: isSeller,
          isVerified: false,
          status: VerificationStatus.notSubmitted,
          sellerStatus: isSeller ? 'Active' : null,
          sellerId: sellerId,
        );
      }),
    ];
  }

  testWidgets('verified user sees no verification banner or reserved gap', (
    WidgetTester tester,
  ) async {
    await tester.pumpTestApp(
      const AccountScreen(),
      overrides: overrides(verified: true),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('account_header_card')), findsOneWidget);
    expect(find.byKey(const Key('account_verification_banner')), findsNothing);
    expect(find.text('Verify your account'), findsNothing);
  });

  testWidgets('account header prefers the backend display name', (
    WidgetTester tester,
  ) async {
    await tester.pumpTestApp(
      const AccountScreen(),
      overrides: overrides(verified: true, displayName: 'Bobby'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bobby'), findsOneWidget);
  });

  testWidgets('unverified user can open the verification choice sheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpTestApp(
      const AccountScreen(),
      overrides: overrides(verified: false),
    );
    await tester.pumpAndSettle();

    final Finder banner = find.byKey(const Key('account_verification_banner'));
    expect(banner, findsOneWidget);

    await tester.tap(banner);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final Finder sheet = find.byKey(const Key('verification_choice_sheet'));
    expect(sheet, findsOneWidget);
    expect(
      find.byKey(const Key('verification_choice_sheet_title')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('Individual')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('Business')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: banner,
        matching: find.byType(CircularProgressIndicator),
      ),
      findsNothing,
    );
  });
  testWidgets('My Storefront uses the canonical seller public ID', (
    WidgetTester tester,
  ) async {
    const sellerId = 'SELLER-ABCDEFGHIJKLMNOPQRST';
    final router = GoRouter(
      initialLocation: '/',
      routes: <RouteBase>[
        GoRoute(path: '/', builder: (_, _) => const AccountScreen()),
        GoRoute(
          name: AppRoutes.nMyStoreFront,
          path: AppRoutes.myStoreFront,
          builder: (_, state) => Scaffold(
            body: Text(state.pathParameters['sellerId'] ?? 'missing'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(
          verified: true,
          isSeller: true,
          sellerId: sellerId,
        ),
        child: MaterialApp.router(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          supportedLocales: kSupportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('My Storefront'));
    await tester.pumpAndSettle();

    expect(find.text(sellerId), findsOneWidget);
    expect(find.text('owner@example.invalid'), findsNothing);
  });

  testWidgets('invalid seller identity never opens My Storefront', (
    WidgetTester tester,
  ) async {
    await tester.pumpTestApp(
      const AccountScreen(),
      overrides: overrides(
        verified: true,
        isSeller: true,
        sellerId: 'owner@example.invalid',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Listings'), findsOneWidget);
    expect(find.text('My Storefront'), findsNothing);
  });
}
