import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final preferenceApiSyncProvider = Provider.autoDispose<PreferenceApiSync>((
  ref,
) {
  final api = ref.read(apiClientProvider);

  final sync = PreferenceApiSync(api, ref)..init();

  ref.onDispose(() {
    // optional cleanup if you ever switch to streams
  });

  return sync;
});

class PreferenceApiSync {
  PreferenceApiSync(this._api, this._ref);

  final ApiClient _api;
  final Ref _ref;

  void init() {
    _ref.listen(userPreferenceControllerProvider, (_, next) {
      _api.setContext(
        countryCode: next.countryCode,
        languageCode: next.languageCode,
        currencyCode: next.currencyCode,
      );
    });
  }
}
