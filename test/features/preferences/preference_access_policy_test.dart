import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/preferences/models/preference_access_policy.dart';
import 'package:africaonlinestores/features/preferences/models/user_preference_field.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('country is locked only when backend lock and seller state agree', () {
    expect(
      PreferenceAccessPolicy.isCountryLocked(
        _authenticated(isSeller: true, backendLocked: true),
      ),
      isTrue,
    );
    expect(
      PreferenceAccessPolicy.isCountryLocked(
        _authenticated(isSeller: false, backendLocked: true),
      ),
      isFalse,
    );
    expect(
      PreferenceAccessPolicy.isCountryLocked(
        _authenticated(isSeller: true, backendLocked: false),
      ),
      isFalse,
    );
    expect(
      PreferenceAccessPolicy.isCountryLocked(const AuthGuest()),
      isFalse,
    );
  });

  test('language and currency remain editable for seller accounts', () {
    final seller = _authenticated(isSeller: true, backendLocked: true);

    expect(
      PreferenceAccessPolicy.canEdit(UserPreferenceField.country, seller),
      isFalse,
    );
    expect(
      PreferenceAccessPolicy.canEdit(UserPreferenceField.language, seller),
      isTrue,
    );
    expect(
      PreferenceAccessPolicy.canEdit(UserPreferenceField.currency, seller),
      isTrue,
    );
  });
}

AuthAuthenticated _authenticated({
  required bool isSeller,
  required bool backendLocked,
}) {
  return AuthAuthenticated(
    user: AuthUser(
      accountId: 'ACC-ABCDEFGHIJKLMNOPQRST',
      email: 'user@example.invalid',
      fullName: 'Test User',
    ),
    sid: 'test-session-id',
    preferences: <String, dynamic>{'is_country_locked': backendLocked},
    seller: AuthSellerSummary(
      isSeller: isSeller,
      sellerId: isSeller ? 'SELLER-ABCDEFGHIJKLMNOPQRST' : null,
      status: isSeller ? 'Active' : null,
    ),
  );
}
