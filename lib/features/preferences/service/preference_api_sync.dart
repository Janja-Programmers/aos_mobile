import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';
import 'package:africaonlinestores/features/preferences/state/user_preference_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final preferenceApiSyncProvider = Provider.autoDispose<PreferenceApiSync>((
  ref,
) {
  final api = ref.read(apiClientProvider);
  return PreferenceApiSync(api, ref)..init();
});

class PreferenceApiSync {
  PreferenceApiSync(this._api, this._ref);

  final ApiClient _api;
  final Ref _ref;
  bool _initialized = false;

  void init() {
    if (_initialized) return;
    _initialized = true;

    _apply(_ref.read(userPreferenceControllerProvider));
    _ref.listen<UserPreferenceState>(
      userPreferenceControllerProvider,
      (_, next) => _apply(next),
    );
  }

  void _apply(UserPreferenceState preferences) {
    _api.setContext(
      countryCode: preferences.countryId,
      languageCode: preferences.languageId,
      currencyCode: preferences.currencyId,
    );
  }
}
