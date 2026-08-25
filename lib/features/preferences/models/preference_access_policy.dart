import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/preferences/models/user_preference_field.dart';

abstract final class PreferenceAccessPolicy {
  static bool canEdit(UserPreferenceField field, AuthState authState) {
    return field != UserPreferenceField.country || !isCountryLocked(authState);
  }

  static bool isCountryLocked(AuthState authState) {
    final authenticated = authState.asAuthenticated;
    if (authenticated == null || !authenticated.seller.isSeller) return false;

    return asBool(authenticated.preferences['is_country_locked']);
  }
}
