import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/routing/app_nav.dart';

import 'package:africaonlinestores/features/ads/ads_form/presentation/pickers/select_location_screen.dart';
import 'package:africaonlinestores/features/connect/routing/connect_routes.dart';
import 'package:africaonlinestores/features/home/domain/location_picker.dart';
import 'package:africaonlinestores/features/home/presentation/components/home_app_bar.dart';
import 'package:africaonlinestores/features/home/presentation/controller/home_page_controller.dart';
import 'package:africaonlinestores/features/home/presentation/screens/ad_list_scaffold.dart';
import 'package:africaonlinestores/features/home/presentation/sections/ads_content.dart';
import 'package:africaonlinestores/features/notifications/navigation/notification_routes.dart';
import 'package:africaonlinestores/features/search/shared/routing/search_routes.dart';

import 'package:africaonlinestores/l10n/l10n_extension.dart';

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

  /// =============================
  /// LOCATION PICKER
  /// =============================
  Future<void> _openLocationPicker() async {
    final currentLocation = ref
        .read(homePageControllerProvider)
        .value
        ?.locationId;

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SelectLocationScreen(selectedId: currentLocation),
      ),
    );

    final picked = LocationPick.fromPopResult(result);

    if (picked == null || picked.id == null) return;

    /// Update location inside HomePageController
    await ref
        .read(homePageControllerProvider.notifier)
        .changeLocation(picked.id!);
  }

  /// =============================
  /// BUILD
  /// =============================
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    /// Watch location label only
    final locationLabel = ref.watch(
      homePageControllerProvider.select((state) => state.value?.locationId),
    );

    final searchBar = AppSearchBar(
      controller: _searchCtrl,
      readOnly: true,
      onTap: () => SearchNavigation.toSearchscreen(context),
      onMicTap: () => SearchNavigation.toSearchscreen(context),
      onCameraTap: () => SearchNavigation.toSearchscreen(context),
    );

    final header = HomeAppBar(
      locationLabel: locationLabel ?? l10n.location_all_locations,
      onTapLocation: _openLocationPicker,
      onTapConnect: () {
        AppNavigation.requireAuth(
          context,
          ref,
          onAuthenticated: () {
            ConnectScreenNavigation.toMessagesTab(context);
          },
        );
      },
      onTapNotifications: () {
        AppNavigation.requireAuth(
          context,
          ref,
          onAuthenticated: () {
            NotificationsNavigation.toNavigations(context);
          },
        );
      },
      search: searchBar,
    );

    return AdListScaffold(
      header: header,
      body: AdListContentView(
        onTapLocation: _openLocationPicker,

        /// Pull-to-refresh
        onRefresh: () async {
          await ref.read(homePageControllerProvider.notifier).refresh();
        },
      ),
    );
  }
}
