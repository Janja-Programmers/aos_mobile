import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/localization/locale_controller.dart';
import 'package:africaonlinestores/core/localization/utils.dart';

import 'package:africaonlinestores/features/home/domain/market_place.dart';

final marketContextProvider =
    AsyncNotifierProvider<MarketContextController, MarketContext>(
      MarketContextController.new,
    );

class MarketContextController extends AsyncNotifier<MarketContext> {
  @override
  Future<MarketContext> build() async {
    final prefs = ref
        .watch(localeControllerProvider)
        .maybeWhen(data: (v) => v, orElse: () => null);

    const fallbackCountry = 'Kenya';
    const fallbackCode = 'KE';

    if (prefs == null) {
      return const MarketContext(
        country: fallbackCountry,
        displayCountryCode: fallbackCode,
      );
    }

    final code = prefs.countryCode.isNotEmpty
        ? prefs.countryCode
        : fallbackCode;

    final bundle = await ref.read(localeBundleProvider.future);
    final resolvedCountry = labelFor(bundle.countries, code) ?? fallbackCountry;

    return MarketContext(country: resolvedCountry, displayCountryCode: code);
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
