import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/localization/utils.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/app_snack.dart';

import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/ui/pickers/select_location_screen.dart';
import 'package:africaonlinestores/features/home/components/home_app_bar.dart';
import 'package:africaonlinestores/features/home/domain/location_picker.dart';
import 'package:africaonlinestores/features/home/ui/ad_list_scaffold.dart';
import 'package:africaonlinestores/features/home/sections/ads_content.dart';
import 'package:africaonlinestores/features/home/sections/ads_error.dart';
import 'package:africaonlinestores/features/home/sections/ads_loading.dart';

import 'package:africaonlinestores/ui/components/app_search_bar.dart';

class AdListScreen extends ConsumerStatefulWidget {
  const AdListScreen({super.key});

  @override
  ConsumerState<AdListScreen> createState() => _AdListScreenState();
}

class _AdListScreenState extends ConsumerState<AdListScreen> {
  final _searchCtrl = TextEditingController();

  final _items = <AOSAdListItem>[];
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _offset = 0;
  static const _limit = 20;

  // Location filter ("All Cities" => null)
  String _locationLabel = 'All Cities';
  String? _locationId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(initial: true);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    _offset = 0;
    _hasMore = true;
    _error = null;
    _items.clear();
    await _load(initial: true);
  }

  Future<void> _load({bool initial = false}) async {
    if (_loading || _loadingMore) return;
    if (!_hasMore && !initial) return;

    final prefs = ref
        .read(localeControllerProvider)
        .maybeWhen(data: (v) => v, orElse: () => null);

    final codeOrLabel = (prefs?.countryCode ?? '').trim();
    if (codeOrLabel.isEmpty) return;

    const fallbackCountryName = 'Kenya';
    String countryName = fallbackCountryName;

    try {
      final bundle = await ref.read(localeBundleProvider.future);
      countryName =
          labelFor(bundle.countries, codeOrLabel) ?? fallbackCountryName;
    } catch (_) {
      countryName = fallbackCountryName;
    }

    if (countryName.trim().isEmpty) return;

    setState(() {
      _error = null;
      if (initial) {
        _loading = true;
      } else {
        _loadingMore = true;
      }
    });

    final res = await ref
        .read(adsApiProvider)
        .listAds(
          countryName: countryName,
          locationId: _locationId,
          q: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
          limit: _limit,
          offset: _offset,
        );

    if (!mounted) return;

    res.fold(
      (f) => setState(() {
        _error = f.message;
      }),
      (data) {
        final payload = data['data'];
        final rawItems = (payload is Map) ? payload['items'] : null;
        if (rawItems is! List) return;

        final list = rawItems
            .whereType<Map<String, dynamic>>()
            .map(AOSAdListItem.fromJson)
            .toList();

        setState(() {
          if (_offset == 0) _items.clear();
          _items.addAll(list);
          _offset += list.length;
          _hasMore = list.length == _limit;
        });
      },
    );

    if (!mounted) return;
    setState(() {
      _loading = false;
      _loadingMore = false;
    });
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SelectLocationScreen(selectedId: _locationId),
      ),
    );

    final picked = LocationPick.fromPopResult(result);
    if (picked == null) return;

    setState(() {
      _locationLabel = picked.label;
      _locationId = picked.id;
    });

    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(localeControllerProvider, (_, _) {
      setState(() {
        _locationLabel = 'All Cities';
        _locationId = null;
      });
      _refresh();
    });

    final prefs = ref
        .watch(localeControllerProvider)
        .maybeWhen(data: (v) => v, orElse: () => null);
    final country = (prefs?.countryCode ?? '').trim();

    final searchBar = AppSearchBar(
      readOnly: true,
      controller: _searchCtrl,
      onTap: () => context.pushNamed(AppRoutes.nSearch),
      onSubmitted: (_) => {},
      onMicTap: () => context.pushNamed(AppRoutes.nSearch),
      onCameraTap: () => context.pushNamed(AppRoutes.nSearch),
    );

    final header = HomeAppBar(
      locationLabel: _locationLabel,
      onTapLocation: _openLocationPicker,
      onTapFavorites: () => ShowSnack(context, 'Coming Soon!').info(),
      onTapNotifications: () => ShowSnack(context, 'Coming Soon!').info(),
      search: searchBar,
    );

    final Widget stateBody;

    if (_loading && _items.isEmpty) {
      stateBody = const AdListLoadingView();
    } else if (_error != null && _items.isEmpty) {
      stateBody = AdListErrorView(message: _error!, onRetry: _refresh);
    } else {
      stateBody = AdListContentView(
        items: _items,
        country: country,
        onLoadMore: _load,
        onRefresh: _refresh,
        loadingMore: _loadingMore,
        hasMore: _hasMore,
        locationLabel: _locationLabel,
        onTapLocation: _openLocationPicker,
      );
    }

    return AdListScaffold(header: header, body: stateBody);
  }
}
