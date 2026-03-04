import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/localization/localization_provider.dart';
import 'package:africaonlinestores/features/account/shared/providers/user_preference_provider.dart';
import 'package:africaonlinestores/features/home/domain/market_place.dart';

class MarketContextController extends AsyncNotifier<MarketContext> {
  @override
  Future<MarketContext> build() async {
    final prefsAsync = ref.watch(userPreferenceControllerProvider);
    final localization = await ref.read(localizationControllerProvider.future);

    const fallbackCode = 'KE';

    final prefs = prefsAsync.maybeWhen(data: (v) => v, orElse: () => null);

    final code = prefs?.country?.isNotEmpty == true
        ? prefs!.country!
        : fallbackCode;

    // Resolve display label using localization state
    final resolved = localization.countries.firstWhere(
      (c) => c["code"] == code,
      orElse: () => {"name": "Kenya", "code": fallbackCode},
    );

    final currency = prefs?.currency?.isNotEmpty == true
        ? prefs!.currency!
        : localization.systemDefaultCurrency ?? 'KES';

    return MarketContext(
      country: resolved["name"],
      displayCountryCode: code,
      currency: currency,
    );
  }

  Future<void> setLocation({required String id, required String label}) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(current.copyWith(locationId: id, locationLabel: label));
  }

  Future<void> clearLocation() async {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(current.copyWith(locationId: null, locationLabel: null));
  }
}
