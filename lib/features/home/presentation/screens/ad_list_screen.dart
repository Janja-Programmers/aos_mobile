import 'package:africaonlinestores/app/bootstrap/app_bootstrap_controller.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// class AdListScreen extends ConsumerStatefulWidget {
//   const AdListScreen({super.key});

//   @override
//   ConsumerState<AdListScreen> createState() => _AdListScreenState();
// }

// class _AdListScreenState extends ConsumerState<AdListScreen> {
//   final _searchCtrl = TextEditingController();

//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }

// Future<void> _openLocationPicker() async {
//   final marketAsync = ref.read(marketContextProvider);

//   final currentLocationId = marketAsync.maybeWhen(
//     data: (m) => m.locationId,
//     orElse: () => null,
//   );

//   final result = await Navigator.of(context).push(
//     MaterialPageRoute(
//       builder: (_) => SelectLocationScreen(selectedId: currentLocationId),
//     ),
//   );

//   final picked = LocationPick.fromPopResult(result);
//   if (picked == null || picked.id == null) {
//     return;
//   }

//   await ref
//       .read(marketContextProvider.notifier)
//       .setLocation(id: picked.id!, label: picked.label);

//   // Now read updated market
//   final updatedMarket = await ref.read(marketContextProvider.future);

//   await ref
//       .read(homePageControllerProvider.notifier)
//       .reloadForMarket(updatedMarket);
// }

// Widget build(BuildContext context) {
//   final marketAsync = ref.watch(marketContextProvider);
//   final searchBar = AppSearchBar(
//     readOnly: true,
//     controller: _searchCtrl,
//     onTap: () => context.pushNamed(AppRoutes.nSearch),
//     onSubmitted: (_) {},
//     onMicTap: () => context.pushNamed(AppRoutes.nSearch),
//     onCameraTap: () => context.pushNamed(AppRoutes.nSearch),
//   );
//   final header = marketAsync.when(
//     loading: () => HomeAppBar(
//       locationLabel: 'All Locations',
//       onTapLocation: () {},
//       onTapFavorites: () {
//         context.pushNamed(
//           AppRoutes.nAllAds,
//           extra: const AllAdsArgs('', null, mode: AllAdsMode.wishlist),
//         );
//       },
//       onTapNotifications: () => ShowSnack(context, 'Coming Soon!').info(),
//       search: searchBar,
//     ),
//     error: (_, _) => HomeAppBar(
//       locationLabel: 'All Locations',
//       onTapLocation: () {},
//       onTapFavorites: () {
//         context.pushNamed(
//           AppRoutes.nAllAds,
//           extra: const AllAdsArgs('', null, mode: AllAdsMode.wishlist),
//         );
//       },
//       onTapNotifications: () => ShowSnack(context, 'Coming Soon!').info(),
//       search: searchBar,
//     ),
//     data: (market) => HomeAppBar(
//       locationLabel: market.locationLabel ?? 'All Locations',
//       onTapLocation: _openLocationPicker,
//       onTapFavorites: () {
//         context.pushNamed(
//           AppRoutes.nAllAds,
//           extra: const AllAdsArgs('', null, mode: AllAdsMode.wishlist),
//         );
//       },
//       onTapNotifications: () => ShowSnack(context, 'Coming Soon!').info(),
//       search: searchBar,
//     ),
//   );
//   return AdListScaffold(
//     header: header,
//     body: AdListContentView(
//       onTapLocation: _openLocationPicker,
//       onRefresh: () async {
//         final market = await ref.read(marketContextProvider.future);
//         await ref
//             .read(homePageControllerProvider.notifier)
//             .reloadForMarket(market);
//       },
//     ),
//   );
// }

class AdListScreen extends ConsumerStatefulWidget {
  const AdListScreen({super.key});

  @override
  ConsumerState<AdListScreen> createState() => _AdListScreenState();
}

class _AdListScreenState extends ConsumerState<AdListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(userPreferenceControllerProvider);

    final l10n = context.l10n;

    final country = onboarding.countryCode;
    final language = onboarding.languageCode;
    final currency = onboarding.currencyCode;

    final auth = ref.watch(authControllerProvider);
    final isAuthenticated = auth.isAuthenticated;

    return Scaffold(
      appBar: AppBar(title: const Text("Ad List")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "🌍 Country: $country\n"
              "💱 Currency: $currency\n"
              "🗣 Language: $language\n"
              "L10N CHECKER: ${l10n.auth_login}\n"
              "User: $isAuthenticated",
              style: const TextStyle(fontSize: 18),
            ),

            TextButton.icon(
              onPressed: () async {
                await ref
                    .read(userPreferenceControllerProvider.notifier)
                    .reset();

                await ref
                    .read(appBootstrapControllerProvider.notifier)
                    .resetOnboarding();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Preferences cleared")),
                  );
                }
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text("RESET SP"),
            ),
          ],
        ),
      ),
    );
  }
}
