import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/features/ads/ads_all/all_ads_controller.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/pickers/select_location_screen.dart';
import 'package:africaonlinestores/features/home/presentation/components/home_app_bar.dart';
import 'package:africaonlinestores/features/home/domain/location_picker.dart';
import 'package:africaonlinestores/features/home/presentation/screens/ad_list_scaffold.dart';
import 'package:africaonlinestores/features/home/presentation/sections/ads_content.dart';

import 'package:africaonlinestores/shared/components/app_search_bar.dart';

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

  Future<void> _openLocationPicker() async {
    final marketAsync = ref.read(marketContextProvider);

    final currentLocationId = marketAsync.maybeWhen(
      data: (m) => m.locationId,
      orElse: () => null,
    );

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SelectLocationScreen(selectedId: currentLocationId),
      ),
    );

    final picked = LocationPick.fromPopResult(result);
    if (picked == null || picked.id == null) {
      return;
    }

    await ref
        .read(marketContextProvider.notifier)
        .setLocation(id: picked.id!, label: picked.label);

    // Invalidate homepage to reload everything
    ref.invalidate(homePageControllerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final marketAsync = ref.watch(marketContextProvider);

    final searchBar = AppSearchBar(
      readOnly: true,
      controller: _searchCtrl,
      onTap: () => context.pushNamed(AppRoutes.nSearch),
      onSubmitted: (_) {},
      onMicTap: () => context.pushNamed(AppRoutes.nSearch),
      onCameraTap: () => context.pushNamed(AppRoutes.nSearch),
    );

    final header = marketAsync.when(
      loading: () => HomeAppBar(
        locationLabel: 'All Cities',
        onTapLocation: () {},
        onTapFavorites: () {
          context.pushNamed(
            AppRoutes.nAllAds,

            extra: const AllAdsArgs('', null, mode: AllAdsMode.wishlist),
          );
        },
        onTapNotifications: () => ShowSnack(context, 'Coming Soon!').info(),
        search: searchBar,
      ),
      error: (_, _) => HomeAppBar(
        locationLabel: 'All Cities',
        onTapLocation: () {},
        onTapFavorites: () {
          context.pushNamed(
            AppRoutes.nAllAds,
            extra: const AllAdsArgs('', null, mode: AllAdsMode.wishlist),
          );
        },
        onTapNotifications: () => ShowSnack(context, 'Coming Soon!').info(),
        search: searchBar,
      ),
      data: (market) => HomeAppBar(
        locationLabel: market.locationLabel ?? 'All Cities',
        onTapLocation: _openLocationPicker,
        onTapFavorites: () {
          context.pushNamed(
            AppRoutes.nAllAds,
            extra: const AllAdsArgs('', null, mode: AllAdsMode.wishlist),
          );
        },
        onTapNotifications: () => ShowSnack(context, 'Coming Soon!').info(),
        search: searchBar,
      ),
    );
    return AdListScaffold(
      header: header,
      body: AdListContentView(
        onTapLocation: _openLocationPicker,
        onRefresh: () async {
          ref.invalidate(homePageControllerProvider);
        },
      ),
    );
  }
}
